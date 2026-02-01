package com.intellidev.ai.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.client.SimpleClientHttpRequestFactory;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@RestController
@RequestMapping("/api/v1")
public class StreamingAIChatController {
    
    private static final Logger logger = LoggerFactory.getLogger(StreamingAIChatController.class);
    
    @Value("${ai.api.key:}")
    private String apiKey;
    
    @Value("${ai.base.url:https://api.deepseek.com}")
    private String baseUrl;
    
    @Value("${ai.model:deepseek-chat}")
    private String model;
    
    @Value("${ai.max.tokens:1000}")
    private int maxTokens;
    
    private final ExecutorService executorService = Executors.newCachedThreadPool();
    
    // 流式聊天端点 - 使用SSE (Server-Sent Events)
    @PostMapping(value = "/chat/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter streamChat(@RequestBody ChatRequest request) {
        logger.info("收到流式聊天请求: {}", request.getMessage());
        
        SseEmitter emitter = new SseEmitter(60000L); // 60秒超时
        
        executorService.execute(() -> {
            try {
                // 检查API Key
                if (apiKey == null || apiKey.isEmpty() || apiKey.equals("your_ai_api_key_here")) {
                    emitter.send(SseEmitter.event()
                        .name("error")
                        .data("{\"error\":\"API Key未配置，请在配置文件中设置ai.api.key\"}"));
                    emitter.complete();
                    return;
                }
                
                // 构建请求URL
                String url = baseUrl + "/chat/completions";
                
                // 构建请求体
                Map<String, Object> requestBody = new HashMap<>();
                requestBody.put("model", model);
                requestBody.put("messages", Arrays.asList(
                    Map.of("role", "user", "content", request.getMessage())
                ));
                requestBody.put("max_tokens", maxTokens);
                requestBody.put("temperature", 0.7);
                requestBody.put("stream", true); // 启用流式响应
                
                String jsonBody = mapToJson(requestBody);
                
                // 发送HTTP请求
                HttpURLConnection connection = null;
                try {
                    URL apiUrl = new URL(url);
                    connection = (HttpURLConnection) apiUrl.openConnection();
                    connection.setRequestMethod("POST");
                    connection.setRequestProperty("Content-Type", "application/json");
                    connection.setRequestProperty("Authorization", "Bearer " + apiKey);
                    connection.setRequestProperty("Accept", "text/event-stream");
                    connection.setDoOutput(true);
                    connection.setConnectTimeout(10000);
                    connection.setReadTimeout(60000);
                    
                    // 发送请求体
                    connection.getOutputStream().write(jsonBody.getBytes(StandardCharsets.UTF_8));
                    
                    // 检查响应
                    int responseCode = connection.getResponseCode();
                    if (responseCode != HttpURLConnection.HTTP_OK) {
                        String error = "API请求失败: " + responseCode;
                        logger.error(error);
                        emitter.send(SseEmitter.event()
                            .name("error")
                            .data("{\"error\":\"" + error + "\"}"));
                        emitter.complete();
                        return;
                    }
                    
                    // 读取流式响应
                    BufferedReader reader = new BufferedReader(
                        new InputStreamReader(connection.getInputStream(), StandardCharsets.UTF_8));
                    
                    String line;
                    StringBuilder fullResponse = new StringBuilder();
                    boolean isFirstChunk = true;
                    
                    while ((line = reader.readLine()) != null) {
                        if (line.startsWith("data: ")) {
                            String data = line.substring(6);
                            
                            if (data.equals("[DONE]")) {
                                // 流结束
                                emitter.send(SseEmitter.event()
                                    .name("complete")
                                    .data("{\"complete\":true,\"full_response\":\"" + 
                                          escapeJson(fullResponse.toString()) + "\"}"));
                                break;
                            }
                            
                            // 解析JSON响应
                            try {
                                Map<String, Object> chunkData = parseJsonChunk(data);
                                if (chunkData != null) {
                                    List<Map<String, Object>> choices = (List<Map<String, Object>>) chunkData.get("choices");
                                    if (choices != null && !choices.isEmpty()) {
                                        Map<String, Object> choice = choices.get(0);
                                        Map<String, Object> delta = (Map<String, Object>) choice.get("delta");
                                        
                                        if (delta != null && delta.containsKey("content")) {
                                            String content = (String) delta.get("content");
                                            fullResponse.append(content);
                                            
                                            // 发送内容块
                                            Map<String, Object> eventData = new HashMap<>();
                                            eventData.put("chunk", content);
                                            eventData.put("is_first", isFirstChunk);
                                            eventData.put("timestamp", System.currentTimeMillis());
                                            
                                            emitter.send(SseEmitter.event()
                                                .data(mapToJson(eventData)));
                                            
                                            if (isFirstChunk) {
                                                isFirstChunk = false;
                                            }
                                        }
                                    }
                                }
                            } catch (Exception e) {
                                logger.warn("解析流式响应块失败: {}", e.getMessage());
                            }
                        }
                    }
                    
                    reader.close();
                    
                    // 发送完成事件
                    emitter.send(SseEmitter.event()
                        .name("complete")
                        .data("{\"complete\":true,\"full_response\":\"" + 
                              escapeJson(fullResponse.toString()) + "\"}"));
                    
                } catch (Exception e) {
                    logger.error("流式请求失败", e);
                    emitter.send(SseEmitter.event()
                        .name("error")
                        .data("{\"error\":\"" + e.getMessage() + "\"}"));
                } finally {
                    if (connection != null) {
                        connection.disconnect();
                    }
                }
                
                emitter.complete();
                
            } catch (Exception e) {
                logger.error("流式处理异常", e);
                emitter.completeWithError(e);
            }
        });
        
        // 设置完成和超时处理
        emitter.onCompletion(() -> logger.info("SSE流完成"));
        emitter.onTimeout(() -> {
            logger.warn("SSE流超时");
            emitter.complete();
        });
        emitter.onError((ex) -> logger.error("SSE流错误", ex));
        
        return emitter;
    }
    
    // 兼容性端点 - 同时支持流式和非流式
    @PostMapping("/chat/compatible")
    public ResponseEntity<Map<String, Object>> compatibleChat(
            @RequestBody ChatRequest request,
            @RequestParam(value = "stream", defaultValue = "false") boolean stream) {
        
        logger.info("收到兼容聊天请求: {}, stream={}", request.getMessage(), stream);
        
        if (stream) {
            // 返回流式响应信息
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "请使用 /api/v1/chat/stream 端点进行流式聊天");
            response.put("stream_endpoint", "/api/v1/chat/stream");
            response.put("timestamp", System.currentTimeMillis());
            return ResponseEntity.ok(response);
        } else {
            // 使用原有的非流式逻辑
            return delegateToOriginalChat(request);
        }
    }
    
    // 代理到原有的聊天端点
    private ResponseEntity<Map<String, Object>> delegateToOriginalChat(ChatRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        // 检查API Key
        if (apiKey == null || apiKey.isEmpty() || apiKey.equals("your_ai_api_key_here")) {
            logger.warn("API Key未配置");
            response.put("success", false);
            response.put("error", "API Key未配置");
            response.put("message", "请在配置文件中设置ai.api.key");
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(response);
        }
        
        try {
            // 使用RestTemplate进行非流式请求
            RestTemplate restTemplate = new RestTemplate();
            SimpleClientHttpRequestFactory requestFactory = new SimpleClientHttpRequestFactory();
            requestFactory.setConnectTimeout(10000);
            requestFactory.setReadTimeout(30000);
            restTemplate.setRequestFactory(requestFactory);
            
            // 构建请求头
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.setBearerAuth(apiKey);
            
            // 构建请求体
            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("model", model);
            requestBody.put("messages", Arrays.asList(
                Map.of("role", "user", "content", request.getMessage())
            ));
            requestBody.put("max_tokens", maxTokens);
            requestBody.put("temperature", 0.7);
            requestBody.put("stream", false);
            
            // 发送请求
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);
            String url = baseUrl + "/chat/completions";
            
            ResponseEntity<Map> apiResponse = restTemplate.exchange(
                url, HttpMethod.POST, entity, Map.class);
            
            // 处理响应
            if (apiResponse.getStatusCode().is2xxSuccessful() && apiResponse.getBody() != null) {
                Map<String, Object> apiBody = apiResponse.getBody();
                List<Map<String, Object>> choices = (List<Map<String, Object>>) apiBody.get("choices");
                if (choices != null && !choices.isEmpty()) {
                    Map<String, Object> choice = choices.get(0);
                    Map<String, Object> message = (Map<String, Object>) choice.get("message");
                    String content = (String) message.get("content");
                    
                    response.put("success", true);
                    response.put("message", content);
                    response.put("model", model);
                    response.put("tokens_used", apiBody.get("usage"));
                    response.put("timestamp", System.currentTimeMillis());
                } else {
                    response.put("success", false);
                    response.put("error", "API返回空响应");
                }
            } else {
                response.put("success", false);
                response.put("error", "API请求失败: " + apiResponse.getStatusCode());
            }
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("error", "请求异常: " + e.getClass().getSimpleName());
            response.put("message", e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }
    
    // 测试流式端点
    @GetMapping(value = "/chat/stream/test", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter testStream() {
        SseEmitter emitter = new SseEmitter(30000L);
        
        executorService.execute(() -> {
            try {
                // 发送测试消息
                String[] testMessages = {
                    "你好！",
                    "我是DeepSeek AI助手。",
                    "我可以帮你解答各种问题。",
                    "这是一个流式响应测试。",
                    "消息正在实时传输。",
                    "测试完成！"
                };
                
                for (int i = 0; i < testMessages.length; i++) {
                    Map<String, Object> eventData = new HashMap<>();
                    eventData.put("chunk", testMessages[i]);
                    eventData.put("index", i);
                    eventData.put("total", testMessages.length);
                    eventData.put("timestamp", System.currentTimeMillis());
                    
                    emitter.send(SseEmitter.event()
                        .data(mapToJson(eventData)));
                    
                    // 模拟延迟
                    Thread.sleep(500);
                }
                
                emitter.send(SseEmitter.event()
                    .name("complete")
                    .data("{\"complete\":true,\"message\":\"测试流式响应完成\"}"));
                
                emitter.complete();
                
            } catch (Exception e) {
                emitter.completeWithError(e);
            }
        });
        
        return emitter;
    }
    
    // 工具方法：Map转JSON字符串
    private String mapToJson(Map<String, Object> map) {
        try {
            StringBuilder json = new StringBuilder("{");
            boolean first = true;
            for (Map.Entry<String, Object> entry : map.entrySet()) {
                if (!first) {
                    json.append(",");
                }
                json.append("\"").append(entry.getKey()).append("\":");
                
                Object value = entry.getValue();
                if (value instanceof String) {
                    json.append("\"").append(escapeJson((String) value)).append("\"");
                } else if (value instanceof Number || value instanceof Boolean) {
                    json.append(value);
                } else {
                    json.append("\"").append(value).append("\"");
                }
                
                first = false;
            }
            json.append("}");
            return json.toString();
        } catch (Exception e) {
            return "{\"error\":\"JSON转换失败\"}";
        }
    }
    
    // 工具方法：解析JSON块
    private Map<String, Object> parseJsonChunk(String json) {
        try {
            // 简化解析，实际应该使用JSON库
            if (json.startsWith("{") && json.endsWith("}")) {
                Map<String, Object> map = new HashMap<>();
                // 简单解析，仅用于演示
                if (json.contains("\"choices\"")) {
                    map.put("has_choices", true);
                }
                return map;
            }
            return null;
        } catch (Exception e) {
            return null;
        }
    }
    
    // 工具方法：转义JSON字符串
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
    
    // 请求数据类
    public static class ChatRequest {
        private String message;
        
        public String getMessage() {
            return message;
        }
        
        public void setMessage(String message) {
            this.message = message;
        }
    }
}
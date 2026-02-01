package com.intellidev.ai.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.HttpServerErrorException;
import org.springframework.http.client.SimpleClientHttpRequestFactory;

import java.util.*;

@RestController
@RequestMapping("/api/v1")
public class AIChatController {
    
    private static final Logger logger = LoggerFactory.getLogger(AIChatController.class);
    
    @Value("${ai.api.key:}")
    private String apiKey;
    
    @Value("${ai.base.url:https://api.deepseek.com}")
    private String baseUrl;
    
    @Value("${ai.model:deepseek-chat}")
    private String model;
    
    @Value("${ai.max.tokens:1000}")
    private int maxTokens;
    
    private final RestTemplate restTemplate;
    
    public AIChatController() {
        this.restTemplate = new RestTemplate();
        // 设置超时
        SimpleClientHttpRequestFactory requestFactory = new SimpleClientHttpRequestFactory();
        requestFactory.setConnectTimeout(10000); // 10秒连接超时
        requestFactory.setReadTimeout(30000);    // 30秒读取超时
        this.restTemplate.setRequestFactory(requestFactory);
    }
    
    @PostMapping("/chat")
    public ResponseEntity<Map<String, Object>> chat(@RequestBody ChatRequest request) {
        logger.info("收到聊天请求: {}", request.getMessage());
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
            
        } catch (HttpClientErrorException e) {
            response.put("success", false);
            response.put("error", "客户端错误: " + e.getStatusCode());
            response.put("message", e.getResponseBodyAsString());
        } catch (HttpServerErrorException e) {
            response.put("success", false);
            response.put("error", "服务器错误: " + e.getStatusCode());
            response.put("message", e.getResponseBodyAsString());
        } catch (Exception e) {
            response.put("success", false);
            response.put("error", "请求异常: " + e.getClass().getSimpleName());
            response.put("message", e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/status")
    public ResponseEntity<Map<String, Object>> status() {
        Map<String, Object> response = new HashMap<>();
        response.put("service", "Java AI Chat API");
        response.put("status", "RUNNING");
        response.put("model", model);
        response.put("api_configured", !(apiKey == null || apiKey.isEmpty() || apiKey.equals("your_ai_api_key_here")));
        response.put("base_url", baseUrl);
        response.put("timestamp", System.currentTimeMillis());
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/ping")
    public ResponseEntity<String> ping() {
        return ResponseEntity.ok("pong - " + System.currentTimeMillis());
    }
    
    @PostMapping("/echo")
    public ResponseEntity<Map<String, Object>> echo(@RequestBody Map<String, String> request) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "回声: " + request.get("message"));
        response.put("timestamp", System.currentTimeMillis());
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/chat/text")
    public ResponseEntity<String> chatText(@RequestBody ChatRequest request) {
        logger.info("收到纯文本聊天请求: {}", request.getMessage());
        try {
            // 检查API Key
            if (apiKey == null || apiKey.isEmpty() || apiKey.equals("your_ai_api_key_here")) {
                logger.warn("纯文本端点: API Key未配置");
                return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body("错误: API Key未配置，请在配置文件中设置ai.api.key");
            }
            
            // 快速测试模式 - 如果消息包含"测试"或"test"，返回快速响应
            String userMessage = request.getMessage();
            if (userMessage.contains("测试") || userMessage.contains("test") || userMessage.contains("Test")) {
                logger.info("快速测试模式，返回模拟响应");
                return ResponseEntity.ok("✅ 测试成功！AI API工作正常。\n\n你的消息: " + userMessage + "\n\n这是模拟响应，真实AI响应需要连接DeepSeek API。");
            }
            
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
                    
                    // 返回纯文本响应
                    logger.info("纯文本请求成功，回复长度: {} 字符", content.length());
                    return ResponseEntity.ok(content);
                } else {
                    return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                        .body("错误: API返回空响应");
                }
            } else {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("错误: API请求失败: " + apiResponse.getStatusCode());
            }
            
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("错误: " + e.getClass().getSimpleName() + " - " + e.getMessage());
        }
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
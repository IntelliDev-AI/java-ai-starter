package com.intellidev.ai;

import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class SimpleAIController {
    
    @GetMapping("/health")
    public Map<String, Object> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("service", "Java AI Starter");
        response.put("message", "服务运行正常，请配置AI_API_KEY以启用AI功能");
        response.put("timestamp", System.currentTimeMillis());
        return response;
    }
    
    @GetMapping("/test")
    public Map<String, Object> test() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Java AI Starter 运行正常");
        response.put("version", "1.0.0");
        response.put("javaVersion", System.getProperty("java.version"));
        return response;
    }
    
    @PostMapping("/chat")
    public Map<String, Object> chat(@RequestBody Map<String, String> request) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "AI功能需要配置API Key。请在.env文件中设置AI_API_KEY");
        response.put("hint", "当前是演示模式，配置后可以连接DeepSeek API");
        response.put("received", request.get("message"));
        return response;
    }
}
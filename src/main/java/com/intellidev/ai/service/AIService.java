package com.intellidev.ai.service;

import com.theokanning.openai.completion.chat.ChatCompletionRequest;
import com.theokanning.openai.completion.chat.ChatMessage;
import com.theokanning.openai.service.OpenAiService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;

@Service
@Slf4j
public class AIService {
    
    @Value("${openai.api-key}")
    private String apiKey;
    
    @Value("${openai.model:gpt-3.5-turbo}")
    private String model;
    
    @Value("${openai.timeout:30000}")
    private Integer timeout;
    
    @Value("${openai.max-tokens:1000}")
    private Integer maxTokens;
    
    private OpenAiService openAiService;
    
    @PostConstruct
    public void init() {
        if (apiKey == null || apiKey.isEmpty()) {
            log.warn("OpenAI API key is not configured. AI features will be disabled.");
            return;
        }
        
        this.openAiService = new OpenAiService(apiKey, Duration.ofMillis(timeout));
        log.info("OpenAI service initialized with model: {}", model);
    }
    
    /**
     * 发送消息给AI并获取回复
     */
    public String chat(String message) {
        if (openAiService == null) {
            return "AI service is not available. Please configure OpenAI API key.";
        }
        
        try {
            List<ChatMessage> messages = new ArrayList<>();
            messages.add(new ChatMessage("user", message));
            
            ChatCompletionRequest request = ChatCompletionRequest.builder()
                    .model(model)
                    .messages(messages)
                    .maxTokens(maxTokens)
                    .build();
            
            ChatMessage response = openAiService.createChatCompletion(request)
                    .getChoices()
                    .get(0)
                    .getMessage();
            
            return response.getContent();
            
        } catch (Exception e) {
            log.error("Error calling OpenAI API", e);
            return "Sorry, I encountered an error: " + e.getMessage();
        }
    }
    
    /**
     * 代码审查功能
     */
    public String reviewCode(String code, String language) {
        if (openAiService == null) {
            return "AI service is not available.";
        }
        
        String prompt = String.format("""
            Please review the following %s code for:
            1. Potential bugs or errors
            2. Code style improvements
            3. Performance optimizations
            4. Security issues
            
            Code:
            ```%s
            %s
            ```
            
            Provide your review in Chinese.
            """, language, language, code);
        
        return chat(prompt);
    }
    
    /**
     * 生成代码文档
     */
    public String generateDocumentation(String code, String language) {
        if (openAiService == null) {
            return "AI service is not available.";
        }
        
        String prompt = String.format("""
            Please generate documentation for the following %s code.
            Include:
            1. Function/class description
            2. Parameters explanation
            3. Return value description
            4. Usage examples
            
            Code:
            ```%s
            %s
            ```
            
            Generate documentation in Chinese.
            """, language, language, code);
        
        return chat(prompt);
    }
    
    /**
     * 检查服务是否可用
     */
    public boolean isAvailable() {
        return openAiService != null;
    }
    
    /**
     * 获取当前使用的模型
     */
    public String getModel() {
        return model;
    }
}
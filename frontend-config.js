// 前端配置文件模板
const config = {
  API_BASE_URL: process.env.REACT_APP_API_URL || 'http://81.70.234.241:8080/api/v1',
  ENDPOINTS: {
    CHAT: '/chat/text',           // 非流式聊天
    CHAT_STREAM: '/chat/stream',   // 流式聊天
    CHAT_COMPATIBLE: '/chat/compatible', // 兼容端点
    CHAT_TEST: '/chat/stream/test', // 流式测试
    PING: '/ping',
    STATUS: '/status',
    ECHO: '/echo'
  }
};

// 生成完整的URL
const getApiUrl = (endpoint) => {
  return `${config.API_BASE_URL}${config.ENDPOINTS[endpoint] || endpoint}`;
};

// 流式响应处理器
class StreamHandler {
  constructor(options = {}) {
    this.onChunk = options.onChunk || (() => {});
    this.onComplete = options.onComplete || (() => {});
    this.onError = options.onError || (() => {});
    this.fullResponse = '';
  }

  // 处理SSE流
  async processStream(url, data) {
    try {
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(data)
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const reader = response.body.getReader();
      const decoder = new TextDecoder('utf-8');
      let buffer = '';

      while (true) {
        const { done, value } = await reader.read();
        
        if (done) {
          this.onComplete(this.fullResponse);
          break;
        }

        buffer += decoder.decode(value, { stream: true });
        const lines = buffer.split('\n');
        buffer = lines.pop() || '';

        for (const line of lines) {
          if (line.startsWith('data: ')) {
            const dataStr = line.substring(6);
            
            if (dataStr === '[DONE]') {
              this.onComplete(this.fullResponse);
              return;
            }

            try {
              const eventData = JSON.parse(dataStr);
              
              if (eventData.chunk) {
                this.fullResponse += eventData.chunk;
                this.onChunk(eventData.chunk, this.fullResponse, eventData);
              } else if (eventData.error) {
                this.onError(eventData.error);
              } else if (eventData.complete) {
                this.onComplete(this.fullResponse);
              }
            } catch (e) {
              console.warn('解析流式数据失败:', e, dataStr);
            }
          }
        }
      }
    } catch (error) {
      this.onError(error.message);
    }
  }

  // 简单的流式请求
  static async simpleStream(url, data, onChunk) {
    const handler = new StreamHandler({ onChunk });
    await handler.processStream(url, data);
    return handler.fullResponse;
  }
}

export default {
  ...config,
  getApiUrl,
  StreamHandler
};
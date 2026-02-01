// 前端配置文件模板
const config = {
  API_BASE_URL: process.env.REACT_APP_API_URL || 'http://81.70.234.241:8080/api/v1',
  ENDPOINTS: {
    CHAT: '/chat/text',
    PING: '/ping',
    STATUS: '/status',
    ECHO: '/echo'
  }
};

// 生成完整的URL
const getApiUrl = (endpoint) => {
  return `${config.API_BASE_URL}${config.ENDPOINTS[endpoint] || endpoint}`;
};

export default {
  ...config,
  getApiUrl
};
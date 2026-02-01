// 前端配置文件
const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://81.70.234.241/api/v1';

const config = {
  API_BASE_URL,
  ENDPOINTS: {
    CHAT: `${API_BASE_URL}/chat/text`,
    PING: `${API_BASE_URL}/ping`,
    STATUS: `${API_BASE_URL}/status`,
    ECHO: `${API_BASE_URL}/echo`
  },
  // 应用信息
  APP_NAME: 'Java AI Starter',
  VERSION: '1.0.0',
  // 服务器信息
  SERVER_IP: '81.70.234.241',
  SERVER_PORT: 80
};

export default config;
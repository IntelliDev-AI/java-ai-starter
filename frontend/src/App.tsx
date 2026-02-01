import React, { useState } from 'react';
import './App.css';
import config from './config';

function App() {
  const [message, setMessage] = useState('');
  const [response, setResponse] = useState('');
  const [loading, setLoading] = useState(false);
  const [connectionStatus, setConnectionStatus] = useState<'unknown' | 'connected' | 'error'>('unknown');

  // 测试后端连接
  const testConnection = async () => {
    try {
      const res = await fetch(config.ENDPOINTS.PING);
      const data = await res.text();
      setConnectionStatus('connected');
      return data;
    } catch (error) {
      setConnectionStatus('error');
      throw error;
    }
  };

  // 发送聊天消息
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!message.trim()) return;
    
    setLoading(true);
    try {
      const res = await fetch(config.ENDPOINTS.CHAT, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ message })
      });
      
      const data = await res.json();
      setResponse(data.response || data.message || JSON.stringify(data, null, 2));
    } catch (error: any) {
      setResponse(`错误: ${error.message}`);
    } finally {
      setLoading(false);
    }
  };

  // 测试回声
  const testEcho = async () => {
    try {
      const res = await fetch(config.ENDPOINTS.ECHO, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ message: '测试回声' })
      });
      
      const data = await res.json();
      setResponse(`回声测试: ${JSON.stringify(data, null, 2)}`);
    } catch (error: any) {
      setResponse(`回声测试错误: ${error.message}`);
    }
  };

  // 检查状态
  const checkStatus = async () => {
    try {
      const res = await fetch(config.ENDPOINTS.STATUS);
      const data = await res.json();
      setResponse(`系统状态: ${JSON.stringify(data, null, 2)}`);
    } catch (error: any) {
      setResponse(`状态检查错误: ${error.message}`);
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>🚀 {config.APP_NAME}</h1>
        <p>版本: {config.VERSION}</p>
        
        <div className="server-info">
          <p>🌐 服务器: {config.SERVER_IP}:{config.SERVER_PORT}</p>
          <p>🔗 API地址: {config.API_BASE_URL}</p>
          <p>状态: 
            <span className={`status ${connectionStatus}`}>
              {connectionStatus === 'connected' ? '✅ 已连接' : 
               connectionStatus === 'error' ? '❌ 连接失败' : '🔍 未测试'}
            </span>
          </p>
        </div>

        <div className="control-panel">
          <button onClick={testConnection} className="btn btn-test">
            测试连接
          </button>
          <button onClick={testEcho} className="btn btn-echo">
            回声测试
          </button>
          <button onClick={checkStatus} className="btn btn-status">
            系统状态
          </button>
        </div>

        <div className="chat-container">
          <h2>💬 AI聊天</h2>
          <form onSubmit={handleSubmit} className="chat-form">
            <textarea
              value={message}
              onChange={(e) => setMessage(e.target.value)}
              placeholder="输入你的消息..."
              rows={4}
              className="chat-input"
              disabled={loading}
            />
            <button 
              type="submit" 
              className="btn btn-send"
              disabled={loading || !message.trim()}
            >
              {loading ? '发送中...' : '发送消息'}
            </button>
          </form>
        </div>

        {response && (
          <div className="response-container">
            <h3>📨 响应:</h3>
            <pre className="response-content">{response}</pre>
            <button 
              onClick={() => setResponse('')}
              className="btn btn-clear"
            >
              清空响应
            </button>
          </div>
        )}

        <div className="api-info">
          <h3>📋 可用API端点:</h3>
          <ul>
            <li><strong>GET</strong> {config.ENDPOINTS.PING} - 连接测试</li>
            <li><strong>POST</strong> {config.ENDPOINTS.CHAT} - AI聊天</li>
            <li><strong>POST</strong> {config.ENDPOINTS.ECHO} - 回声测试</li>
            <li><strong>GET</strong> {config.ENDPOINTS.STATUS} - 系统状态</li>
          </ul>
        </div>

        <footer className="footer">
          <p>© 2026 IntelliDev-AI - Java AI Starter 项目</p>
          <p>GitHub: <a href="https://github.com/IntelliDev-AI/java-ai-starter" target="_blank" rel="noopener noreferrer">IntelliDev-AI/java-ai-starter</a></p>
        </footer>
      </header>
    </div>
  );
}

export default App;
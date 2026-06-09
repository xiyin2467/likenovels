import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';

// 前端开发服务器；/api 代理到零依赖 Node 后端 (server/，默认 4000 端口)
export default defineConfig({
  plugins: [react(), tailwindcss()],
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: process.env.API_TARGET || 'http://localhost:4000',
        changeOrigin: true,
      },
    },
  },
});

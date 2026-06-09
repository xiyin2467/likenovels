import { createContext, useContext, useEffect, useState } from 'react';
import { api, getToken, setToken, clearToken } from './api.js';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [ready, setReady] = useState(false);

  useEffect(() => {
    let active = true;
    async function boot() {
      if (getToken()) {
        try {
          const { user } = await api.me();
          if (active) setUser(user);
        } catch {
          clearToken();
        }
      }
      if (active) setReady(true);
    }
    boot();

    const onExpired = () => setUser(null);
    window.addEventListener('auth:expired', onExpired);
    return () => {
      active = false;
      window.removeEventListener('auth:expired', onExpired);
    };
  }, []);

  async function login(username, password) {
    const res = await api.login(username, password);
    setToken(res.token);
    setUser(res.user);
    return res.user;
  }

  function logout() {
    clearToken();
    setUser(null);
  }

  return (
    <AuthContext.Provider value={{ user, ready, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);

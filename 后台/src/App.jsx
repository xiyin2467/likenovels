import { Routes, Route, Navigate, useLocation } from 'react-router-dom';
import { useAuth } from './auth.jsx';
import Layout from './components/Layout.jsx';
import { Spinner } from './components/ui.jsx';
import Login from './pages/Login.jsx';
import Dashboard from './pages/Dashboard.jsx';
import Books from './pages/Books.jsx';
import BookDetail from './pages/BookDetail.jsx';
import Users from './pages/Users.jsx';
import Orders from './pages/Orders.jsx';
import Monetization from './pages/Monetization.jsx';

function Protected({ children }) {
  const { user, ready } = useAuth();
  const location = useLocation();
  if (!ready) {
    return (
      <div className="grid h-full place-items-center">
        <Spinner label="正在加载…" />
      </div>
    );
  }
  if (!user) return <Navigate to="/login" replace state={{ from: location }} />;
  return <Layout>{children}</Layout>;
}

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route path="/" element={<Protected><Dashboard /></Protected>} />
      <Route path="/books" element={<Protected><Books /></Protected>} />
      <Route path="/books/:id" element={<Protected><BookDetail /></Protected>} />
      <Route path="/users" element={<Protected><Users /></Protected>} />
      <Route path="/orders" element={<Protected><Orders /></Protected>} />
      <Route path="/monetization" element={<Protected><Monetization /></Protected>} />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}

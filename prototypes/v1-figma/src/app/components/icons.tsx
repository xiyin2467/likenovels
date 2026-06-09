import {
  ChevronLeft, ChevronRight, Search, Home, BookOpen, User, Bell,
  Coins, Sparkles, SlidersHorizontal, Play, Heart, List, Type,
  RefreshCw, Plus, Gift, Lock, Clock, Settings, Star, Flame,
  Check, CheckCircle, Globe, Shield, Trash2, Bookmark, Languages,
  Mail, Wallet, ArrowRight, X, Eye, MoreHorizontal, Filter,
  TrendingUp, Zap, CircleDollarSign, ChevronDown, AlertCircle,
} from 'lucide-react';

export {
  ChevronLeft, ChevronRight, Search, Home, BookOpen, User, Bell,
  Coins, Sparkles, SlidersHorizontal, Play, Heart, List, Type,
  RefreshCw, Plus, Gift, Lock, Clock, Settings, Star, Flame,
  Check, CheckCircle, Globe, Shield, Trash2, Bookmark, Languages,
  Mail, Wallet, ArrowRight, X, Eye, MoreHorizontal, Filter,
  TrendingUp, Zap, CircleDollarSign, ChevronDown, AlertCircle,
};

export function HeartFill({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 24 24" fill="currentColor" className={className}>
      <path d="M12 21.593c-.524-.249-8.592-5.08-8.592-10.189 0-2.87 2.26-5.206 5.049-5.206 1.39 0 2.713.578 3.69 1.594a5.12 5.12 0 0 1 3.544-1.594c2.789 0 5.05 2.337 5.05 5.206 0 5.11-8.069 9.94-8.741 10.189z" />
    </svg>
  );
}

export function CoinIcon({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.85" strokeLinecap="round" strokeLinejoin="round" className={className}>
      <circle cx="12" cy="12" r="9" />
      <path d="M9 12h6M12 9v6" />
      <path d="M9.5 9.5c.6-.6 1.5-1 2.5-1s1.9.4 2.5 1" />
      <path d="M9.5 14.5c.6.6 1.5 1 2.5 1s1.9-.4 2.5-1" />
    </svg>
  );
}

export function GoogleIcon({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 24 24" className={className}>
      <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" />
      <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" />
      <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" />
      <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" />
    </svg>
  );
}

export function FacebookIcon({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 24 24" fill="#1877F2" className={className}>
      <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z" />
    </svg>
  );
}

export function SparkIcon({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 24 24" fill="currentColor" className={className}>
      <path d="M12 2l1.09 3.26L16 6.18l-2.91 2.12L14 12l-2-1.5L10 12l.91-3.7L8 6.18l2.91-.92z" />
      <path d="M19 8l.5 1.5L21 10l-1.5.5L19 12l-.5-1.5L17 10l1.5-.5z" opacity=".6" />
      <path d="M7 14l.5 1.5L9 16l-1.5.5L7 18l-.5-1.5L5 16l1.5-.5z" opacity=".6" />
    </svg>
  );
}

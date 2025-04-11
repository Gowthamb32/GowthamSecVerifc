import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate, useLocation } from 'react-router-dom';
import { ThemeProvider, CssBaseline } from '@mui/material';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import axios from 'axios';
import { useAuth, AuthProvider } from './contexts/AuthContext';
import { useNavigate } from 'react-router-dom';
import { Box, CircularProgress } from '@mui/material';

// Theme
import forgeTheme from './themes/forgeTheme';

// Pages
import Login from './pages/Login';
import Register from './pages/Register';
import Dashboard from './pages/Dashboard';
import Projects from './pages/Projects';
import ProjectDetails from './pages/ProjectDetails';
import CreateProject from './pages/CreateProject';
import Profile from './pages/Profile';
import AdminPanel from './pages/AdminPanel';
import NotFound from './pages/NotFound';

// Create a client for React Query
const queryClient = new QueryClient();

// Protected Route component
const ProtectedRoute: React.FC<{ element: React.ReactNode; allowedRoles?: string[] }> = ({ 
  element, 
  allowedRoles = [] 
}) => {
  const { isAuthenticated, user } = useAuth();
  const [documents, setDocuments] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();
  const location = useLocation();
  
  useEffect(() => {
    const fetchDocuments = async () => {
      if (!user) return;
      try {
        const response = await axios.get('/api/documents');
        setDocuments(response.data);
      } catch (err) {
        console.error('Error fetching documents:', err);
      } finally {
        setLoading(false);
      }
    };

    fetchDocuments();
  }, [user]);

  if (!isAuthenticated) {
    return <Navigate to="/login" />;
  }
  
  if (allowedRoles.length > 0 && user && !allowedRoles.includes(user.role)) {
    return <Navigate to="/dashboard" />;
  }

  // Check if user has verified documents
  const hasVerifiedDocuments = documents.some(doc => doc.status === 'VERIFIED');
  const isFullyVerified = user?.status === 'Verified' && hasVerifiedDocuments;

  // If user is not fully verified and trying to access a protected route
  // Allow access to profile page even when not fully verified
  if (!isFullyVerified && !loading && location.pathname !== '/profile') {
    return <Navigate to="/profile" />;
  }
  
  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="100vh">
        <CircularProgress />
      </Box>
    );
  }
  
  return <>{element}</>;
};

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider theme={forgeTheme}>
        <CssBaseline />
        <AuthProvider>
          <Router>
            <Routes>
              {/* Public Routes */}
              <Route path="/login" element={<Login />} />
              <Route path="/register" element={<Register />} />
              
              {/* Protected Routes */}
              <Route path="/dashboard" element={
                <ProtectedRoute element={<Dashboard />} />
              } />
              <Route path="/projects" element={
                <ProtectedRoute element={<Projects />} />
              } />
              <Route path="/projects/create" element={
                <ProtectedRoute element={<CreateProject />} allowedRoles={['Innovator']} />
              } />
              <Route path="/projects/:id" element={
                <ProtectedRoute element={<ProjectDetails />} />
              } />
              <Route path="/profile" element={
                <ProtectedRoute element={<Profile />} />
              } />
              
              {/* Admin Routes */}
              <Route path="/admin" element={
                <ProtectedRoute element={<AdminPanel />} allowedRoles={['Admin', 'EscrowManager']} />
              } />
              
              {/* Redirect root to dashboard if authenticated, otherwise login */}
              <Route path="/" element={<Navigate to="/dashboard" />} />
              
              {/* 404 Page */}
              <Route path="*" element={<NotFound />} />
            </Routes>
          </Router>
        </AuthProvider>
      </ThemeProvider>
    </QueryClientProvider>
  );
}

export default App;
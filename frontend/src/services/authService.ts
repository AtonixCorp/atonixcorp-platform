import axios from 'axios';
import {
  User,
  LoginRequest,
  LoginResponse,
  SignupRequest,
  SignupResponse,
  CommunityMember,
  Discussion,
  DiscussionReply
} from '../types/auth';

// Create axios instance for auth
const authApi = axios.create({
  baseURL: '/api/auth',
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add request interceptor to include auth token
authApi.interceptors.request.use((config) => {
  console.log('Auth API request:', config.method?.toUpperCase(), config.url, config.data);
  const token = localStorage.getItem('authToken');
  if (token) {
    config.headers.Authorization = `Token ${token}`;
  }
  return config;
});

// Add response interceptor for debugging
authApi.interceptors.response.use(
  (response) => {
    console.log('Auth API response success:', response.status, response.data);
    return response;
  },
  (error) => {
    console.error('Auth API response error:', error.response?.status, error.response?.data, error.message);
    return Promise.reject(error);
  }
);

// Auth Services
export const authService = {
  login: async (credentials: LoginRequest): Promise<LoginResponse> => {
    console.log('AuthService login called with:', credentials);
    try {
      const response = await authApi.post<LoginResponse>('/login/', credentials);
      console.log('AuthService login response:', response.data);
      return response.data;
    } catch (error) {
      console.error('AuthService login error:', error);
      throw error;
    }
  },

  signup: async (userData: SignupRequest): Promise<SignupResponse> => {
    console.log('AuthService signup called with:', userData);
    try {
      const response = await authApi.post<SignupResponse>('/signup/', userData);
      console.log('AuthService signup response:', response.data);
      return response.data;
    } catch (error) {
      console.error('AuthService signup error:', error);
      throw error;
    }
  },

  logout: async (): Promise<void> => {
    await authApi.post('/logout/');
  },

  getCurrentUser: async (): Promise<User> => {
    const response = await authApi.get<{ user: User }>('/me/');
    return response.data.user;
  },
};

// Mock Community Services (for features not yet implemented in backend)
export const mockCommunityService = {
  getMembers: async (): Promise<CommunityMember[]> => {
    // Simulate API delay
    await new Promise(resolve => setTimeout(resolve, 500));
    
    return [
      {
        id: 1,
        user: {
          id: 1,
          username: 'johndoe',
          email: 'john@example.com',
          first_name: 'John',
          last_name: 'Doe',
          avatar: '/avatars/john.jpg',
          bio: 'Full-stack developer with expertise in React and Python.',
          github_url: 'https://github.com/johndoe',
          linkedin_url: 'https://linkedin.com/in/johndoe',
          location: 'New York, NY',
          skills: ['React', 'Python', 'Django', 'TypeScript'],
          is_active: true,
          date_joined: '2024-01-15T10:30:00Z',
          last_login: '2024-03-20T14:45:00Z',
        },
        role: 'maintainer',
        contributions: 156,
        reputation: 2847,
        badges: ['Contributor', 'Code Reviewer', 'Community Helper'],
        joined_date: '2024-01-15T10:30:00Z',
        last_active: '2024-03-20T14:45:00Z',
      },
      {
        id: 2,
        user: {
          id: 2,
          username: 'sarahchen',
          email: 'sarah@example.com',
          first_name: 'Sarah',
          last_name: 'Chen',
          avatar: '/avatars/sarah.jpg',
          bio: 'DevOps engineer passionate about cloud infrastructure.',
          github_url: 'https://github.com/sarahchen',
          skills: ['Docker', 'Kubernetes', 'AWS', 'Python'],
          is_active: true,
          date_joined: '2024-02-01T09:15:00Z',
          last_login: '2024-03-19T16:20:00Z',
        },
        role: 'contributor',
        contributions: 89,
        reputation: 1523,
        badges: ['Contributor', 'DevOps Expert'],
        joined_date: '2024-02-01T09:15:00Z',
        last_active: '2024-03-19T16:20:00Z',
      },
      {
        id: 3,
        user: {
          id: 3,
          username: 'mikewilson',
          email: 'mike@example.com',
          first_name: 'Mike',
          last_name: 'Wilson',
          avatar: '/avatars/mike.jpg',
          bio: 'Frontend specialist with a focus on user experience.',
          github_url: 'https://github.com/mikewilson',
          linkedin_url: 'https://linkedin.com/in/mikewilson',
          skills: ['React', 'TypeScript', 'CSS', 'UX Design'],
          is_active: true,
          date_joined: '2024-01-20T14:20:00Z',
          last_login: '2024-03-18T11:30:00Z',
        },
        role: 'member',
        contributions: 42,
        reputation: 756,
        badges: ['Contributor'],
        joined_date: '2024-01-20T14:20:00Z',
        last_active: '2024-03-18T11:30:00Z',
      },
    ];
  },

  getDiscussions: async (): Promise<Discussion[]> => {
    // Simulate API delay
    await new Promise(resolve => setTimeout(resolve, 500));
    
    return [
      {
        id: 1,
        title: 'Best practices for microservices architecture',
        content: 'I\'m working on a new project that requires a microservices architecture. What are some best practices you would recommend for designing and implementing microservices?',
        author: {
          id: 1,
          username: 'johndoe',
          email: 'john@example.com',
          first_name: 'John',
          last_name: 'Doe',
          skills: [],
          is_active: true,
          date_joined: '2024-01-15T10:30:00Z',
        },
        category: 'general',
        tags: ['microservices', 'architecture', 'best-practices'],
        likes: 15,
        replies: 8,
        is_pinned: false,
        is_locked: false,
        created_at: '2024-03-15T10:30:00Z',
        updated_at: '2024-03-18T14:20:00Z',
      },
      {
        id: 2,
        title: 'Help with Docker containerization',
        content: 'I\'m having trouble containerizing my Django application. The container builds successfully but crashes when I try to run it. Here\'s my Dockerfile...',
        author: {
          id: 3,
          username: 'mikewilson',
          email: 'mike@example.com',
          first_name: 'Mike',
          last_name: 'Wilson',
          skills: [],
          is_active: true,
          date_joined: '2024-01-20T14:20:00Z',
        },
        category: 'help',
        tags: ['docker', 'django', 'containerization'],
        likes: 7,
        replies: 12,
        is_pinned: false,
        is_locked: false,
        created_at: '2024-03-14T09:15:00Z',
        updated_at: '2024-03-17T16:45:00Z',
      },
      {
        id: 3,
        title: 'Showcase: AI-powered analytics dashboard',
        content: 'I\'ve been working on an analytics dashboard that uses machine learning to provide predictive insights. Here\'s a demo and the source code...',
        author: {
          id: 2,
          username: 'sarahchen',
          email: 'sarah@example.com',
          first_name: 'Sarah',
          last_name: 'Chen',
          skills: [],
          is_active: true,
          date_joined: '2024-02-01T09:15:00Z',
        },
        category: 'showcase',
        tags: ['ai', 'machine-learning', 'dashboard', 'analytics'],
        likes: 23,
        replies: 6,
        is_pinned: true,
        is_locked: false,
        created_at: '2024-03-12T15:20:00Z',
        updated_at: '2024-03-16T10:30:00Z',
      },
    ];
  },
};

export default authService;
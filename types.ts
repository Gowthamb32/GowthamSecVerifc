// src/types.ts - This file should be in the same directory as the AdminLogic's parent directory

// User interface
export interface User {
    id: string;
    name: string;
    email: string;
    role: 'Admin' | 'Innovator' | 'Investor' | 'EscrowManager';
    status?: 'PendingApproval' | 'Verified' | 'Rejected' | 'Suspended';
    registeredDate: string;
    documents?: string[];
    phone_number?: string;
    address?: string;
    date_of_birth?: string;
  }
  
  // Project interface
  export interface Project {
    id: string;
    title: string;
    innovator: string;
    innovatorId?: string;
    submittedDate: string;
    category: string;
    fundingGoal: number;
    currentFunding?: number;
    status?: 'PendingApproval' | 'SeekingFunding' | 'PartiallyFunded' | 'FullyFunded' | 'InProgress' | 'Completed' | 'Rejected';
    description?: string;
    sdgAlignment?: string[];
    geoFocus?: string;
  }
  
  // Milestone interface
  export interface Milestone {
    id: string;
    project: string;
    projectId?: string;
    innovator: string;
    description: string;
    submittedDate: string;
    fundingRequired: number;
    status?: 'Planned' | 'InProgress' | 'PendingVerification' | 'Approved' | 'Rejected';
    targetCompletionDate?: string;
    startDate?: string;
    title?: string;
  }
  
  // Escrow transaction interface
  export interface EscrowTransaction {
    id: string;
    project: string;
    projectId?: string;
    milestone: string;
    milestoneId?: string;
    amount: number;
    requestDate: string;
    status?: 'Locked' | 'Released' | 'Refunded';
    releasedAt?: string;
    releasedBy?: string;
  }
  
  // Transaction interface
  export interface Transaction {
    id: string;
    userId: string;
    userName: string;
    type: 'deposit' | 'withdrawal' | 'investment' | 'escrow_release' | 'refund';
    amount: number;
    date: string;
    status: 'pending' | 'verifying' | 'completed' | 'rejected';
    paymentMethod?: 'bank_transfer' | 'cryptocurrency' | 'credit_card';
    proofOfPayment?: string;
    project?: string;
    projectId?: string;
    notes?: string;
    riskLevel?: 'low' | 'medium' | 'high';
    walletId?: string;
  }
  
  // Message interface
  export interface Message {
    id: string;
    from: string;
    fromId: string;
    subject: string;
    content: string;
    received: string;
    priority: 'low' | 'medium' | 'high';
    replied?: boolean;
  }
  
  // System health interface
  export interface SystemHealth {
    status: 'healthy' | 'warning' | 'error';
    uptime: string;
    databaseConnections: number;
    activeUsers: number;
    cpuUsage: number;
    memoryUsage: number;
    lastBackup: string;
  }
  
  // User activity interface
  export interface UserActivity {
    id: string;
    action: string;
    timestamp: string;
    details?: string;
  }
  
  // Dashboard stats interface
  export interface DashboardStats {
    totalUsers: number;
    activeProjects: number;
    pendingApprovals: number;
    escrowFunds: number;
    recentActivity: RecentActivity[];
  }
  
  // Recent activity interface
  export interface RecentActivity {
    id: string;
    type: string;
    timestamp: string;
    user?: string;
    project?: string;
    amount?: number;
    milestone?: string;
    investor?: string;
  }
  
  // API response interface
  export interface ApiResponse<T> {
    success: boolean;
    data?: T;
    error?: string;
    message?: string;
  }
  
  // Auth context interface
  export interface AuthContextType {
    user: User | null;
    isAuthenticated: boolean;
    login: (email: string, password: string) => Promise<boolean>;
    logout: () => Promise<void>;
    loading: boolean;
  }
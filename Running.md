 Running the Application

## Prerequisites
- Node.js (v14 or higher)
- PostgreSQL (v12 or higher)
- npm or yarn package manager

## Database Setup

1. Create the database:
```bash
psql -U postgres
CREATE DATABASE innocap_forge;
\q
```

2. Run the database migrations:
```bash
cd database
psql -d innocap_forge -f schema.sql
psql -d innocap_forge -f migrations.sql
```

## Application Properties

### Backend Configuration
Create a `.env` file in the `server` directory with the following properties:
```env
PORT=5000
DB_HOST=localhost
DB_PORT=5432
DB_NAME=innocap_forge
DB_USER=postgres
DB_PASSWORD=your_password
JWT_SECRET=your_jwt_secret_key
```

### Frontend Configuration
Create a `.env` file in the `client` directory with the following properties:
```env
REACT_APP_API_URL=http://localhost:5000/api
```

## Installing Dependencies

### Backend
```bash
cd server
npm install
```

### Frontend
```bash
cd client
npm install
```

## Running the Application

### Backend
```bash
cd server
npm run dev
```
The backend will run on http://localhost:5000

### Frontend
```bash
cd client
npm start
```
The frontend will run on http://localhost:3000

## Database Commands

### Verify a User Account
```bash
psql -d innocap_forge -c "UPDATE users SET status = 'Verified' WHERE email = 'user@example.com';"
```

### Make a User an Admin
```bash
psql -d innocap_forge -c "UPDATE users SET role = 'Admin' WHERE email = 'user@example.com';"
```

### Check User Status
```bash
psql -d innocap_forge -c "SELECT email, role, status FROM users WHERE email = 'user@example.com';"
```

### Check Document Status
```bash
psql -d innocap_forge -c "SELECT d.document_id, d.document_type, d.status, d.created_at FROM documents d JOIN users u ON d.user_id = u.user_id WHERE u.email = 'user@example.com';"
```

### Update Document Status
```bash
psql -d innocap_forge -c "UPDATE documents SET status = 'PENDING' WHERE document_id = document_id;"
```


## Troubleshooting

### Database Connection Issues
1. Ensure PostgreSQL is running
2. Check database credentials in .env file
3. Verify database exists and migrations are applied

### Backend Issues
1. Check if all dependencies are installed
2. Verify environment variables are set correctly
3. Check server logs for errors

### Frontend Issues
1. Clear browser cache
2. Check if backend API is accessible
3. Verify environment variables are set correctly

## Security Notes
- Never commit .env files to version control
- Use strong passwords in production
- Keep JWT_SECRET secure and unique
- Regularly update dependencies for security patches

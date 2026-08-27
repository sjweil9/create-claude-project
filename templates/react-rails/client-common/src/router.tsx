import { createBrowserRouter } from 'react-router-dom'
import App from './App'
import LoginPage from './features/auth/LoginPage'
import ProtectedRoute from './features/auth/ProtectedRoute'
import SignupPage from './features/auth/SignupPage'
import HomePage from './features/home/HomePage'

export const router = createBrowserRouter([
  {
    path: '/',
    element: <App />,
    children: [
      {
        element: <ProtectedRoute />,
        children: [{ index: true, element: <HomePage /> }],
      },
      { path: 'login', element: <LoginPage /> },
      { path: 'signup', element: <SignupPage /> },
    ],
  },
])

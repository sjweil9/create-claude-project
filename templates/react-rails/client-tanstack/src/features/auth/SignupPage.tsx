import { zodResolver } from '@hookform/resolvers/zod'
import { useForm } from 'react-hook-form'
import { Link, Navigate, useNavigate } from '@tanstack/react-router'
import { z } from 'zod'
import { isApiError } from '../../lib/api/client'
import { useAuthStore } from '../../stores/useAuthStore'

const signupSchema = z
  .object({
    email: z.email('Enter a valid email address'),
    password: z.string().min(8, 'At least 8 characters'),
    passwordConfirmation: z.string(),
  })
  .refine((values) => values.password === values.passwordConfirmation, {
    message: 'Passwords do not match',
    path: ['passwordConfirmation'],
  })

type SignupValues = z.infer<typeof signupSchema>

export default function SignupPage() {
  const status = useAuthStore((state) => state.status)
  const signup = useAuthStore((state) => state.signup)
  const navigate = useNavigate()
  const {
    register,
    handleSubmit,
    setError,
    formState: { errors, isSubmitting },
  } = useForm<SignupValues>({ resolver: zodResolver(signupSchema) })

  if (status === 'authenticated') return <Navigate to="/" replace />

  const onSubmit = handleSubmit(async (values) => {
    try {
      await signup(values.email, values.password, values.passwordConfirmation)
      await navigate({ to: '/', replace: true })
    } catch (error) {
      setError('root', {
        message: isApiError(error) ? error.message : 'Sign up failed',
      })
    }
  })

  return (
    <section className="mx-auto w-full max-w-md">
      <div className="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
        <h1 className="mb-6 text-xl font-semibold">Sign up</h1>
        <form onSubmit={(event) => void onSubmit(event)} noValidate>
          {errors.root && (
            <p className="mb-4 rounded-md bg-red-50 p-3 text-sm text-red-800">
              {errors.root.message}
            </p>
          )}
          <div className="mb-4">
            <label
              htmlFor="email"
              className="mb-1 block text-sm font-medium text-gray-700"
            >
              Email
            </label>
            <input
              id="email"
              type="email"
              autoComplete="email"
              className="block w-full rounded-md border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500"
              {...register('email')}
            />
            {errors.email && (
              <p className="mt-1 text-xs text-red-600">
                {errors.email.message}
              </p>
            )}
          </div>
          <div className="mb-4">
            <label
              htmlFor="password"
              className="mb-1 block text-sm font-medium text-gray-700"
            >
              Password
            </label>
            <input
              id="password"
              type="password"
              autoComplete="new-password"
              className="block w-full rounded-md border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500"
              {...register('password')}
            />
            {errors.password && (
              <p className="mt-1 text-xs text-red-600">
                {errors.password.message}
              </p>
            )}
          </div>
          <div className="mb-6">
            <label
              htmlFor="passwordConfirmation"
              className="mb-1 block text-sm font-medium text-gray-700"
            >
              Confirm password
            </label>
            <input
              id="passwordConfirmation"
              type="password"
              autoComplete="new-password"
              className="block w-full rounded-md border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500"
              {...register('passwordConfirmation')}
            />
            {errors.passwordConfirmation && (
              <p className="mt-1 text-xs text-red-600">
                {errors.passwordConfirmation.message}
              </p>
            )}
          </div>
          <button
            type="submit"
            disabled={isSubmitting}
            className="w-full rounded-md bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-700 disabled:opacity-50"
          >
            {isSubmitting ? 'Signing up…' : 'Sign up'}
          </button>
        </form>
        <p className="mt-6 text-sm text-gray-600">
          Already have an account?{' '}
          <Link
            to="/login"
            className="font-medium text-indigo-600 hover:text-indigo-500"
          >
            Log in
          </Link>
        </p>
      </div>
    </section>
  )
}

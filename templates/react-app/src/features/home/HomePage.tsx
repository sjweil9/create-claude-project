export default function HomePage() {
  return (
    <section>
      <h1 className="text-3xl font-bold tracking-tight">
        {'{{PROJECT_NAME}}'}
      </h1>
      <p className="mt-4 text-gray-600">
        Scaffolded and ready. Run the project interview (first{' '}
        <code className="rounded bg-gray-200 px-1">claude</code> session) to
        define what this app does.
      </p>
    </section>
  )
}

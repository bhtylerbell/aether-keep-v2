import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
import Link from "next/link";
import { signOut } from "@/app/(auth)/actions";

export default async function DashboardPage() {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect("/sign-in");
  }

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <nav className="bg-white shadow-sm dark:bg-gray-800">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="flex h-16 justify-between">
            <div className="flex">
              <div className="flex flex-shrink-0 items-center">
                <h1 className="text-xl font-bold text-gray-900 dark:text-white">
                  Aether Keep
                </h1>
              </div>
            </div>
            <div className="flex items-center gap-4">
              <span className="text-sm text-gray-700 dark:text-gray-300">
                {user.email}
              </span>
              <form action={signOut}>
                <button
                  type="submit"
                  className="rounded-md bg-gray-100 px-3 py-2 text-sm font-medium text-gray-700 hover:bg-gray-200 dark:bg-gray-700 dark:text-gray-300 dark:hover:bg-gray-600"
                >
                  Sign out
                </button>
              </form>
            </div>
          </div>
        </div>
      </nav>

      <main className="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
        <div className="mb-8">
          <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
            Welcome to Aether Keep!
          </h2>
          <p className="mt-2 text-gray-600 dark:text-gray-400">
            Your TTRPG campaign and world management platform
          </p>
        </div>

        <div className="grid gap-6 md:grid-cols-3">
          <Link
            href="/campaigns"
            className="rounded-lg border-2 border-dashed border-gray-300 p-6 hover:border-blue-500 dark:border-gray-700 dark:hover:border-blue-500"
          >
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
              Campaign Manager
            </h3>
            <p className="mt-2 text-sm text-gray-600 dark:text-gray-400">
              Manage your TTRPG campaigns, sessions, and players
            </p>
          </Link>

          <Link
            href="/worlds"
            className="rounded-lg border-2 border-dashed border-gray-300 p-6 hover:border-blue-500 dark:border-gray-700 dark:hover:border-blue-500"
          >
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
              World Building
            </h3>
            <p className="mt-2 text-sm text-gray-600 dark:text-gray-400">
              Create and organize your custom worlds and lore
            </p>
          </Link>

          <Link
            href="/systems"
            className="rounded-lg border-2 border-dashed border-gray-300 p-6 hover:border-blue-500 dark:border-gray-700 dark:hover:border-blue-500"
          >
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
              System Building
            </h3>
            <p className="mt-2 text-sm text-gray-600 dark:text-gray-400">
              Build custom game systems or use official ones
            </p>
          </Link>
        </div>

        <div className="mt-8 rounded-lg bg-blue-50 p-4 dark:bg-blue-900/20">
          <p className="text-sm text-blue-800 dark:text-blue-200">
            🚧 This is an early development version. Features are being actively
            built. Stay tuned for updates!
          </p>
        </div>
      </main>
    </div>
  );
}

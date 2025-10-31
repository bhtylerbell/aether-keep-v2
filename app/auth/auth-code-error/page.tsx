import Link from "next/link";

export default function AuthCodeErrorPage() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-gray-50 px-4 py-12 dark:bg-gray-900 sm:px-6 lg:px-8">
      <div className="w-full max-w-md space-y-8">
        <div className="rounded-md bg-red-50 p-4 dark:bg-red-900/20">
          <div className="flex">
            <div className="ml-3">
              <h3 className="text-sm font-medium text-red-800 dark:text-red-200">
                Authentication Error
              </h3>
              <div className="mt-2 text-sm text-red-700 dark:text-red-300">
                <p>
                  There was a problem with your authentication link. This could
                  happen if:
                </p>
                <ul className="mt-2 list-disc pl-5 space-y-1">
                  <li>The link has expired</li>
                  <li>The link has already been used</li>
                  <li>The link is invalid</li>
                </ul>
              </div>
              <div className="mt-4 space-x-3">
                <Link
                  href="/sign-in"
                  className="text-sm font-medium text-red-800 hover:text-red-700 dark:text-red-200"
                >
                  Try signing in again
                </Link>
                <Link
                  href="/sign-up"
                  className="text-sm font-medium text-red-800 hover:text-red-700 dark:text-red-200"
                >
                  Create a new account
                </Link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

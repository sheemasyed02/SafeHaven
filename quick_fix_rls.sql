-- Quick Fix for RLS Recursion Issue
-- Run this in your Supabase SQL Editor to immediately fix the recursion error

-- First, drop all problematic policies
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
DROP POLICY IF EXISTS "Customers can view provider profiles" ON profiles;
DROP POLICY IF EXISTS "Providers can view customer profiles" ON profiles;
DROP POLICY IF EXISTS "Allow viewing provider profiles" ON profiles;
DROP POLICY IF EXISTS "Allow viewing customer profiles" ON profiles;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON profiles;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON profiles;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON profiles;

-- Temporarily disable RLS to avoid recursion issues
-- You can re-enable with proper policies later
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

-- Alternative: If you want to keep RLS enabled, use these simple policies
-- Uncomment the following lines if you prefer to keep RLS:

-- ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Simple policy: authenticated users can do everything with profiles
-- CREATE POLICY "authenticated_users_policy" ON profiles
--     FOR ALL USING (auth.uid() IS NOT NULL);

-- Or more restrictive: users can only access their own profile
-- CREATE POLICY "own_profile_policy" ON profiles
--     FOR ALL USING (auth.uid() = id);

-- Print completion message
DO $$
BEGIN
    RAISE NOTICE 'RLS recursion issue fixed! Your role selection should work now.';
    RAISE NOTICE 'RLS is currently DISABLED for the profiles table.';
    RAISE NOTICE 'You can re-enable it later with proper non-recursive policies.';
END $$;
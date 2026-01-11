-- =====================================================
-- Supabase Setup Script for Todo App
-- Run this in your Supabase SQL Editor
-- =====================================================

-- Create the todos table
CREATE TABLE IF NOT EXISTS public.todos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create index on user_id for faster queries
CREATE INDEX IF NOT EXISTS idx_todos_user_id ON public.todos(user_id);

-- Create index on created_at for ordering
CREATE INDEX IF NOT EXISTS idx_todos_created_at ON public.todos(created_at DESC);

-- Enable Row Level Security
ALTER TABLE public.todos ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only view their own todos
CREATE POLICY "Users can view own todos"
    ON public.todos
    FOR SELECT
    USING (auth.uid() = user_id);

-- Policy: Users can only insert their own todos
CREATE POLICY "Users can insert own todos"
    ON public.todos
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can only update their own todos
CREATE POLICY "Users can update own todos"
    ON public.todos
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can only delete their own todos
CREATE POLICY "Users can delete own todos"
    ON public.todos
    FOR DELETE
    USING (auth.uid() = user_id);

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to call the function on update
DROP TRIGGER IF EXISTS update_todos_updated_at ON public.todos;
CREATE TRIGGER update_todos_updated_at
    BEFORE UPDATE ON public.todos
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- Grant permissions
GRANT ALL ON public.todos TO authenticated;
GRANT USAGE ON SCHEMA public TO authenticated;

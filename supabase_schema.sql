-- ====================================================================
-- FALCONATE CRM (falconate.com) - SUPABASE DATABASE SCHEMA
-- Project: https://avoioogdnbyivinkamup.supabase.co
-- Run this in your Supabase Dashboard -> SQL Editor -> New Query -> Run
-- ====================================================================

-- 1. Enable UUID extension
create extension if not exists "uuid-ossp";

-- 2. Create Leads Table
create table if not exists public.leads (
    id text primary key,
    business_name text not null,
    instagram_username text default '',
    services text default '',
    phone_numbers text default '',
    email text default '',
    location text default '',
    instagram_followers integer default 0,
    instagram_posts integer default 0,
    website_status text default 'No matching website verified',
    website_link text default '',
    lead_priority text default 'Medium', -- 'High', 'Medium', 'Low'
    call_status text default 'Not Called', -- 'Not Called', 'Called - No Answer', 'Connected', 'Interested', 'Follow-up Scheduled', 'Pitch Sent', 'Closed Won', 'Not Interested', 'Invalid Number'
    last_call_date timestamp with time zone,
    next_follow_up_date timestamp with time zone,
    notes text default '',
    caution_notes text default '',
    is_company_verified boolean default true,
    is_nested_data_verified boolean default false,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. Create Call Logs / Interactions Table
create table if not exists public.call_logs (
    id uuid default uuid_generate_v4() primary key,
    lead_id text references public.leads(id) on delete cascade,
    outcome text not null, -- 'Interested', 'Follow-up', 'No Answer', 'Busy', 'Not Interested', 'Wrong Number'
    notes text default '',
    next_follow_up_date timestamp with time zone,
    duration_seconds integer default 0,
    pitched_offering text default 'Website Development', -- 'Website Development', 'Mobile App', 'Website Redesign', 'SEO/Maintenance', 'Custom Solution'
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 4. Create Pitch Templates Table
create table if not exists public.pitch_templates (
    id text primary key,
    title text not null,
    channel text not null, -- 'WhatsApp', 'Email', 'Call Script', 'Instagram DM'
    content text not null,
    is_active boolean default true,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 5. Enable Row Level Security (RLS)
alter table public.leads enable row level security;
alter table public.call_logs enable row level security;
alter table public.pitch_templates enable row level security;

-- 6. Create RLS Policies (Allow read/write with anon key for Falconate CRM)
create policy "Allow anon all on leads" on public.leads for all using (true) with check (true);
create policy "Allow anon all on call_logs" on public.call_logs for all using (true) with check (true);
create policy "Allow anon all on pitch_templates" on public.pitch_templates for all using (true) with check (true);

-- 7. Create Indexes for fast filtering and searching
create index if not exists idx_leads_call_status on public.leads(call_status);
create index if not exists idx_leads_lead_priority on public.leads(lead_priority);
create index if not exists idx_leads_next_follow_up on public.leads(next_follow_up_date);
create index if not exists idx_call_logs_lead_id on public.call_logs(lead_id);

-- 8. Seed Default Pitch Templates for Falconate (falconate.com)
insert into public.pitch_templates (id, title, channel, content)
values 
(
  'wa_web_pitch',
  'Falconate - Website Outreach',
  'WhatsApp',
  'Hi {{name}}, greetings from Falconate (falconate.com)! 🚀 We came across your business {{name}} in {{location}} and noticed your impressive work in {{services}}. We build modern, high-speed, mobile-responsive websites that turn visitors into paying customers. Would you be open to a quick 5-min demo or free audit of your digital presence?'
),
(
  'wa_app_pitch',
  'Falconate - Mobile App Pitch',
  'WhatsApp',
  'Hello {{name}}, this is Falconate Solutions! We specialize in custom Flutter mobile apps (Android & iOS) designed specifically for businesses offering {{services}}. We can help you automate client bookings, catalog browsing, and lead capture. Would you like to see a brief demo this week?'
),
(
  'wa_redesign_pitch',
  'Falconate - Redesign & SEO',
  'WhatsApp',
  'Hi {{name}}, we reviewed {{website}} and love what you are building! At Falconate, we help established businesses scale with modern UI redesigns, Google SEO ranking, and lightning-fast load speeds. Let us know if you would like a free performance audit report.'
)
on conflict (id) do nothing;

-- Create sellers table
CREATE TABLE public.sellers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_name TEXT NOT NULL,
    initials TEXT,
    business_type TEXT,
    rating NUMERIC DEFAULT 0,
    member_since DATE,
    address TEXT,
    is_online BOOLEAN DEFAULT false,
    profile_image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Create products table
CREATE TABLE public.products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seller_id UUID REFERENCES public.sellers(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    category TEXT,
    image_url TEXT,
    price NUMERIC,
    strikethrough_price NUMERIC,
    moq INT,
    stock INT,
    status TEXT CHECK (status IN ('inStock', 'lowStock', 'outOfStock', 'draft')),
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Create buyers table
CREATE TABLE public.buyers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_name TEXT,
    initials TEXT,
    customer_type TEXT,
    credits INT DEFAULT 0,
    active_level TEXT,
    address TEXT,
    is_online BOOLEAN DEFAULT false,
    profile_image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.sellers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.buyers ENABLE ROW LEVEL SECURITY;

-- Public read policies
CREATE POLICY "Public read access for sellers" ON public.sellers FOR SELECT USING (true);
CREATE POLICY "Public read access for products" ON public.products FOR SELECT USING (true);
CREATE POLICY "Public read access for buyers" ON public.buyers FOR SELECT USING (true);

-- Temporary public insert policies
CREATE POLICY "Public insert access for sellers" ON public.sellers FOR INSERT WITH CHECK (true);
CREATE POLICY "Public insert access for products" ON public.products FOR INSERT WITH CHECK (true);
CREATE POLICY "Public insert access for buyers" ON public.buyers FOR INSERT WITH CHECK (true);

-- Seed data
WITH new_sellers AS (
    INSERT INTO public.sellers (company_name, business_type, rating, member_since, address, is_online)
    VALUES
        ('TECHCORP BD', 'Distributor', 4.5, '2021-03-15', 'Dhaka', true),
        ('FURNI B2B', 'Manufacturer', 4.2, '2020-07-01', 'Chattogram', false),
        ('CAFE EQUIP', 'Distributor', 4.7, '2019-11-20', 'Rajshahi', true),
        ('NETWORKS BD', 'Manufacturer', 4.0, '2022-01-10', 'Sylhet', false)
    RETURNING id, company_name
)
INSERT INTO public.products (seller_id, name, category, price, strikethrough_price, moq, stock, status)
SELECT 
    s.id,
    p.name,
    p.category,
    CAST(p.price AS NUMERIC),
    CAST(p.strikethrough_price AS NUMERIC),
    CAST(p.moq AS INT),
    CAST(p.stock AS INT),
    p.status
FROM new_sellers s
JOIN (
    VALUES
        ('TECHCORP BD', 'Dell Inspiron 15 3000 Series Laptop', 'Electronics', 52000, 55000, 5, 24, 'inStock'),
        ('FURNI B2B', 'Ergonomic Mesh Office Chair Pro', 'Home & Garden', 12500, NULL, 20, 4, 'lowStock'),
        ('CAFE EQUIP', 'Breville Commercial Espresso Machine 2000', 'Industrial', 280000, NULL, 1, 0, 'outOfStock'),
        ('NETWORKS BD', 'Cat6a Industrial Ethernet Cable 305m', 'Electronics', 14200, NULL, 10, 0, 'draft')
) AS p(company_name, name, category, price, strikethrough_price, moq, stock, status)
ON s.company_name = p.company_name;

INSERT INTO public.buyers (user_name, customer_type, credits, active_level, address, is_online)
VALUES
    ('Global Trade', 'Buyer', 2450, 'Active Level', 'Rajshahi', true);

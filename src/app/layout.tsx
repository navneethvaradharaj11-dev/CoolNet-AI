import type { Metadata } from 'next';
import 'leaflet/dist/leaflet.css';
import './globals.css';

export const metadata: Metadata = {
  title: 'CoolNet AI — Compound Heat–Grid Risk Intelligence',
  description: 'Climate-risk decision-support platform for compound heat-grid risk assessment',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="bg-[#070b14] text-[#d4d9e4] antialiased">
        {children}
      </body>
    </html>
  );
}

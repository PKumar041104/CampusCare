import "./globals.css";

export const metadata = {
  title: "CampusCare | Smart Campus Maintenance",
  description: "A connected campus maintenance and service request portal.",
};

export default function RootLayout({children}:{children:React.ReactNode}) {
  return <html lang="en"><body>{children}</body></html>;
}

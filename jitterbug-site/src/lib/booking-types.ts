export type BookingStatus = "pending" | "confirmed" | "declined" | "cancelled";

export interface Booking {
  id: string;
  name: string;
  email: string;
  phone: string;
  eventType: string;
  eventDate: string;
  eventLocation: string;
  eventAddress: string;
  package: string;
  message: string;
  status: BookingStatus;
  bookingRef: string;
  createdAt: string; // ISO
  updatedAt: string;
}

export interface BookingFormData {
  name: string;
  email: string;
  phone: string;
  eventType: string;
  eventDate: string;
  eventLocation: string;
  eventAddress: string;
  package: string;
  message: string;
}

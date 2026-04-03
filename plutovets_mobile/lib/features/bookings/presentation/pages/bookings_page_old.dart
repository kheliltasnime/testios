import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/app_placeholder_state.dart';
import '../../../../core/router.dart';
import '../../data/booking_service.dart';
import '../../data/models/booking_models.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final BookingService _bookingService = BookingService();
  bool _isLoading = true;
  List<Booking> _bookings = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bookings = await _bookingService.getUserBookings();
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      // Si erreur d'authentification, rediriger vers login
      if (e.toString().contains('Non connecté') ||
          e.toString().contains('Session expirée')) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.go(AppRouter.login);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(title: 'Mes Rendez-vous', child: _buildBody());
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const AppPlaceholderState(
        icon: Icons.calendar_today,
        title: 'Chargement...',
        message: 'Récupération de vos rendez-vous',
      );
    }

    if (_error != null) {
      return AppPlaceholderState(
        icon: Icons.error_outline,
        title: 'Erreur',
        message: _error!,
        actionLabel: 'Réessayer',
        onAction: _loadBookings,
      );
    }

    if (_bookings.isEmpty) {
      return const AppPlaceholderState(
        icon: Icons.event_available,
        title: 'Aucun rendez-vous',
        message: 'Vous n\'avez pas encore de rendez-vous programmés',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _bookings.length,
      itemBuilder: (context, index) {
        final booking = _bookings[index];
        return _BookingCard(booking: booking);
      },
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pets, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    booking.serviceName ?? 'Service',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatusChip(
                  status: BookingStatus.values.firstWhere(
                    (e) => e.name == booking.status,
                    orElse: () => BookingStatus.pending,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.pets, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  booking.petName ?? 'Animal',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  _formatDate(booking.bookingDate),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            if (booking.location != BookingLocation.clinic) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    booking.location == BookingLocation.home
                        ? 'À domicile'
                        : 'En clinique',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
            if (booking.notes != null && booking.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.note, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.notes!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusChip extends StatelessWidget {
  final BookingStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case BookingStatus.pending:
        color = Colors.orange;
        label = 'En attente';
        break;
      case BookingStatus.confirmed:
        color = Colors.green;
        label = 'Confirmé';
        break;
      case BookingStatus.cancelled:
        color = Colors.red;
        label = 'Annulé';
        break;
      case BookingStatus.completed:
        color = Colors.blue;
        label = 'Terminé';
        break;
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

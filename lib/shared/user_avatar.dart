import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

const _kFallbackAvatarUrl =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCdpRCk005ydvTYNhxqXV_Al-_DO2Jl0tTooALBZPKxYFHzqY6V6PYSOUwCOTd3qYiaKqbSjQSSZqf7Y_WQmZO1KJyOXDmfj-2F5PvyKMkfxdFiRYhxIPhkW9dCF0jtVea2GtMIM8zzagZhLOKjdnM4tLiCU-ml3A3a1lUitIz0FpaH8nPXTcyNLvdBAly3dEWbBQUv1GCzTNMAXv8HZw2ZLgL2XuvQfE6x4yxiZWw6PplA7A6Av0Li0ac-xP5LpGbYFO6Nh-S0pbw';

/// Returns a [NetworkImage] for the current Firebase user's photo,
/// falling back to a default avatar if none is set.
NetworkImage userAvatarImage() {
  final url = FirebaseAuth.instance.currentUser?.photoURL ?? _kFallbackAvatarUrl;
  return NetworkImage(url);
}

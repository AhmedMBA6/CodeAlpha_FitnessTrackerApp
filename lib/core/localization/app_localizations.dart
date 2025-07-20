import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // General
      'app_name': 'Fitness Tracker',
      'ok': 'OK',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'close': 'Close',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'retry': 'Retry',
      'settings': 'Settings',
      
      // Navigation
      'dashboard': 'Dashboard',
      'goals': 'Goals',
      'activities': 'Activities',
      'tracking': 'Tracking',
      'profile': 'Profile',
      'analytics': 'Analytics',
      
      // Goals
      'my_goals': 'My Goals',
      'add_goal': 'Add Goal',
      'edit_goal': 'Edit Goal',
      'goal_details': 'Goal Details',
      'goal_type': 'Goal Type',
      'distance_goal': 'Distance Goal',
      'destination_goal': 'Destination Goal',
      'goal_description': 'Goal Description',
      'goal_distance': 'Goal Distance',
      'goal_progress': 'Goal Progress',
      'goal_completed': 'Goal Completed',
      'goal_in_progress': 'Goal In Progress',
      'goal_not_started': 'Goal Not Started',
      'goal_nearly_complete': 'Goal Nearly Complete',
      'goal_overdue': 'Goal Overdue',
      'set_goal': 'Set Goal',
      'create_goal': 'Create Goal',
      'delete_goal': 'Delete Goal',
      'delete_goal_confirmation': 'Are you sure you want to delete this goal?',
      'no_goals': 'No goals yet!',
      'no_goals_message': 'Start your fitness journey by creating a goal.',
      'create_first_goal': 'Create Your First Goal',
      
      // Activities
      'activity_log': 'Activity Log',
      'add_activity': 'Add Activity',
      'edit_activity': 'Edit Activity',
      'activity_type': 'Activity Type',
      'activity_date': 'Activity Date',
      'activity_duration': 'Activity Duration',
      'activity_distance': 'Activity Distance',
      'activity_description': 'Activity Description',
      'running': 'Running',
      'walking': 'Walking',
      'cycling': 'Cycling',
      'hiking': 'Hiking',
      'swimming': 'Swimming',
      
      // Tracking
      'route_tracking': 'Route Tracking',
      'start_tracking': 'Start Tracking',
      'stop_tracking': 'Stop Tracking',
      'pause_tracking': 'Pause Tracking',
      'resume_tracking': 'Resume Tracking',
      'route_name': 'Route Name',
      'route_details': 'Route Details',
      'route_history': 'Route History',
      'route_export': 'Export Route',
      'route_import': 'Import Route',
      'route_share': 'Share Route',
      'select_goal': 'Select a Goal to Track',
      'no_goals_available': 'No Goals Available',
      'no_goals_message_tracking': 'You don\'t have any active goals to track.\n\nCreate a goal first in the Goals section, then come back to start tracking!',
      
      // Analytics
      'goal_analytics': 'Goal Analytics & Stats',
      'goal_status_breakdown': 'Goal Status Breakdown',
      'in_progress': 'In Progress',
      'total_goals': 'Total Goals',
      'goals_completed': 'Goals Completed',
      'goals_in_progress': 'Goals In Progress',
      'completion_rate': 'Completion Rate',
      'total_activities': 'Total Activities',
      'logs_linked_to_goals': 'Logs Linked to Goals',
      'total_distance': 'Total Distance',
      'best_streak': 'Best Streak',
      'destination_goals_real_road': 'Destination Goals: Real Road Distance',
      'average_road_distance': 'Average Road Distance',
      'total_road_distance': 'Total Road Distance',
      'road_distance': 'Road Distance',
      'est_duration': 'Est. Duration',
      'recent_achievements': 'Recent Achievements',
      'no_recent_achievements': 'No recent achievements yet. Complete a goal to earn your first badge!',
      
      // Map
      'map': 'Map',
      'tap_to_set_start': 'Tap the map to set the start point.',
      'tap_to_set_end': 'Tap the map to set the end point.',
      'set_start_to_location': 'Set Start to My Location',
      'start_point': 'Start Point',
      'end_point': 'End Point',
      'current_location': 'Current Location',
      
      // Stats
      'distance': 'Distance',
      'duration': 'Duration',
      'speed': 'Speed',
      'average_speed': 'Average Speed',
      'max_speed': 'Max Speed',
      'elevation': 'Elevation',
      'paused': 'Paused',
      'start_time': 'Start Time',
      'end_time': 'End Time',
      
      // Units
      'km': 'km',
      'm': 'm',
      'km_h': 'km/h',
      'm_s': 'm/s',
      'hours': 'hours',
      'minutes': 'minutes',
      'seconds': 'seconds',
      'days': 'days',
      
      // Messages
      'goal_saved': 'Goal saved!',
      'goal_updated': 'Goal updated!',
      'goal_deleted': 'Goal deleted!',
      'activity_saved': 'Activity saved!',
      'activity_updated': 'Activity updated!',
      'activity_deleted': 'Activity deleted!',
      'route_saved': 'Route saved!',
      'route_exported': 'Route exported!',
      'route_imported': 'Route imported!',
      'route_shared': 'Route shared!',
      'goal_completed_congratulations': 'Congratulations! You completed your goal!',
      
      // Errors
      'location_services_off': 'Location services are OFF. Please turn them on.',
      'location_permission_required': 'Location permission is required.',
      'location_permission_denied': 'Location permission is permanently denied. Please enable it in settings.',
      'failed_to_get_location': 'Failed to get current location',
      'failed_to_load_map': 'Failed to load map tiles',
      'failed_to_fetch_route': 'Failed to fetch route',
      'no_route_found': 'No route found.',
      'failed_to_export_data': 'Failed to export data',
      'failed_to_import_data': 'Failed to import data',
      'invalid_file_format': 'Invalid file format',
      
      // Permissions
      'open_location_settings': 'Open Location Settings',
      'permission_denied': 'Permission Denied',
      'permission_denied_message': 'This app needs location permission to track your routes.',
      
      // Filters
      'all': 'All',
      'show_all': 'Show All',
      
      // Time
      'today': 'Today',
      'yesterday': 'Yesterday',
      'this_week': 'This Week',
      'this_month': 'This Month',
      'last_week': 'Last Week',
      'last_month': 'Last Month',
    },
    'es': {
      // Spanish translations
      'app_name': 'Rastreador de Fitness',
      'ok': 'OK',
      'cancel': 'Cancelar',
      'save': 'Guardar',
      'delete': 'Eliminar',
      'edit': 'Editar',
      'close': 'Cerrar',
      'loading': 'Cargando...',
      'error': 'Error',
      'success': 'Éxito',
      'retry': 'Reintentar',
      'settings': 'Configuración',
      
      'dashboard': 'Panel',
      'goals': 'Objetivos',
      'activities': 'Actividades',
      'tracking': 'Seguimiento',
      'profile': 'Perfil',
      'analytics': 'Análisis',
      
      'my_goals': 'Mis Objetivos',
      'add_goal': 'Agregar Objetivo',
      'edit_goal': 'Editar Objetivo',
      'goal_details': 'Detalles del Objetivo',
      'goal_type': 'Tipo de Objetivo',
      'distance_goal': 'Objetivo de Distancia',
      'destination_goal': 'Objetivo de Destino',
      'goal_description': 'Descripción del Objetivo',
      'goal_distance': 'Distancia del Objetivo',
      'goal_progress': 'Progreso del Objetivo',
      'goal_completed': 'Objetivo Completado',
      'goal_in_progress': 'Objetivo en Progreso',
      'goal_not_started': 'Objetivo No Iniciado',
      'goal_nearly_complete': 'Objetivo Casi Completado',
      'goal_overdue': 'Objetivo Atrasado',
      'set_goal': 'Establecer Objetivo',
      'create_goal': 'Crear Objetivo',
      'delete_goal': 'Eliminar Objetivo',
      'delete_goal_confirmation': '¿Estás seguro de que quieres eliminar este objetivo?',
      'no_goals': '¡Aún no hay objetivos!',
      'no_goals_message': 'Comienza tu viaje de fitness creando un objetivo.',
      'create_first_goal': 'Crea Tu Primer Objetivo',
      
      'running': 'Corriendo',
      'walking': 'Caminando',
      'cycling': 'Ciclismo',
      'hiking': 'Senderismo',
      'swimming': 'Natación',
      
      'distance': 'Distancia',
      'duration': 'Duración',
      'speed': 'Velocidad',
      'average_speed': 'Velocidad Promedio',
      'max_speed': 'Velocidad Máxima',
      'elevation': 'Elevación',
      'paused': 'Pausado',
      'start_time': 'Hora de Inicio',
      'end_time': 'Hora de Fin',
      
      'km': 'km',
      'm': 'm',
      'km_h': 'km/h',
      'm_s': 'm/s',
      'hours': 'horas',
      'minutes': 'minutos',
      'seconds': 'segundos',
      'days': 'días',
    },
    'fr': {
      // French translations
      'app_name': 'Suivi de Fitness',
      'ok': 'OK',
      'cancel': 'Annuler',
      'save': 'Enregistrer',
      'delete': 'Supprimer',
      'edit': 'Modifier',
      'close': 'Fermer',
      'loading': 'Chargement...',
      'error': 'Erreur',
      'success': 'Succès',
      'retry': 'Réessayer',
      'settings': 'Paramètres',
      
      'dashboard': 'Tableau de Bord',
      'goals': 'Objectifs',
      'activities': 'Activités',
      'tracking': 'Suivi',
      'profile': 'Profil',
      'analytics': 'Analyses',
      
      'my_goals': 'Mes Objectifs',
      'add_goal': 'Ajouter un Objectif',
      'edit_goal': 'Modifier l\'Objectif',
      'goal_details': 'Détails de l\'Objectif',
      'goal_type': 'Type d\'Objectif',
      'distance_goal': 'Objectif de Distance',
      'destination_goal': 'Objectif de Destination',
      'goal_description': 'Description de l\'Objectif',
      'goal_distance': 'Distance de l\'Objectif',
      'goal_progress': 'Progrès de l\'Objectif',
      'goal_completed': 'Objectif Terminé',
      'goal_in_progress': 'Objectif en Cours',
      'goal_not_started': 'Objectif Non Commencé',
      'goal_nearly_complete': 'Objectif Presque Terminé',
      'goal_overdue': 'Objectif en Retard',
      'set_goal': 'Définir l\'Objectif',
      'create_goal': 'Créer un Objectif',
      'delete_goal': 'Supprimer l\'Objectif',
      'delete_goal_confirmation': 'Êtes-vous sûr de vouloir supprimer cet objectif ?',
      'no_goals': 'Aucun objectif pour le moment !',
      'no_goals_message': 'Commencez votre parcours fitness en créant un objectif.',
      'create_first_goal': 'Créez Votre Premier Objectif',
      
      'running': 'Course',
      'walking': 'Marche',
      'cycling': 'Vélo',
      'hiking': 'Randonnée',
      'swimming': 'Natation',
      
      'distance': 'Distance',
      'duration': 'Durée',
      'speed': 'Vitesse',
      'average_speed': 'Vitesse Moyenne',
      'max_speed': 'Vitesse Maximale',
      'elevation': 'Élévation',
      'paused': 'En Pause',
      'start_time': 'Heure de Début',
      'end_time': 'Heure de Fin',
      
      'km': 'km',
      'm': 'm',
      'km_h': 'km/h',
      'm_s': 'm/s',
      'hours': 'heures',
      'minutes': 'minutes',
      'seconds': 'secondes',
      'days': 'jours',
    },
  };

  String get(String key) {
    final languageCode = locale.languageCode;
    final translations = _localizedValues[languageCode] ?? _localizedValues['en']!;
    return translations[key] ?? key;
  }

  String get appName => get('app_name');
  String get ok => get('ok');
  String get cancel => get('cancel');
  String get save => get('save');
  String get delete => get('delete');
  String get edit => get('edit');
  String get close => get('close');
  String get loading => get('loading');
  String get error => get('error');
  String get success => get('success');
  String get retry => get('retry');
  String get settings => get('settings');
  
  String get dashboard => get('dashboard');
  String get goals => get('goals');
  String get activities => get('activities');
  String get tracking => get('tracking');
  String get profile => get('profile');
  String get analytics => get('analytics');
  
  String get myGoals => get('my_goals');
  String get addGoal => get('add_goal');
  String get editGoal => get('edit_goal');
  String get goalDetails => get('goal_details');
  String get goalType => get('goal_type');
  String get distanceGoal => get('distance_goal');
  String get destinationGoal => get('destination_goal');
  String get goalDescription => get('goal_description');
  String get goalDistance => get('goal_distance');
  String get goalProgress => get('goal_progress');
  String get goalCompleted => get('goal_completed');
  String get goalInProgress => get('goal_in_progress');
  String get goalNotStarted => get('goal_not_started');
  String get goalNearlyComplete => get('goal_nearly_complete');
  String get goalOverdue => get('goal_overdue');
  String get setGoal => get('set_goal');
  String get createGoal => get('create_goal');
  String get deleteGoal => get('delete_goal');
  String get deleteGoalConfirmation => get('delete_goal_confirmation');
  String get noGoals => get('no_goals');
  String get noGoalsMessage => get('no_goals_message');
  String get createFirstGoal => get('create_first_goal');
  
  String get running => get('running');
  String get walking => get('walking');
  String get cycling => get('cycling');
  String get hiking => get('hiking');
  String get swimming => get('swimming');
  
  String get distance => get('distance');
  String get duration => get('duration');
  String get speed => get('speed');
  String get averageSpeed => get('average_speed');
  String get maxSpeed => get('max_speed');
  String get elevation => get('elevation');
  String get paused => get('paused');
  String get startTime => get('start_time');
  String get endTime => get('end_time');
  
  String get km => get('km');
  String get m => get('m');
  String get kmH => get('km_h');
  String get mS => get('m_s');
  String get hours => get('hours');
  String get minutes => get('minutes');
  String get seconds => get('seconds');
  String get days => get('days');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
} 
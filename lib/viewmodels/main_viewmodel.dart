import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/career_role_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class MainViewModel extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  UserModel? _currentUser;
  List<CareerRoleModel> _roles = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _userRank = 0;

  UserModel? get currentUser => _currentUser;
  List<CareerRoleModel> get roles => _roles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get userRank => _userRank;

  List<String> get allSkills {
    final Set<String> skillSet = {};
    for (var role in _roles) {
      skillSet.addAll(role.requiredSkills);
    }
    final sortedSkills = skillSet.toList()..sort();
    return sortedSkills;
  }

  bool get isProfileComplete =>
      _currentUser != null &&
      _currentUser!.education != null &&
      _currentUser!.careerGoal != null;

  void onUserChanged(String? uid) {
    if (uid == null) {
      _currentUser = null;
      _roles = [];
      _errorMessage = null;
      notifyListeners();
    } else {
      fetchUserProfile(uid);
      fetchCareerRoles();
    }
  }

  Future<void> fetchUserProfile(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = await _dbService.getUserProfile(uid);
      if (_currentUser != null) {
        await fetchUserRank();
        if (_currentUser!.lastLearningTime != null) {
          NotificationService()
              .scheduleDailyReminder(_currentUser!.lastLearningTime!);
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load profile. Please check your connection.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserRank() async {
    if (_currentUser == null) return;
    try {
      _userRank = await _dbService.getUserRank(_currentUser!.points);
    } catch (e) {
      print('ERROR: Failed to fetch rank: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateLastLearningTime() async {
    if (_currentUser == null) return;
    final now = DateTime.now();
    _currentUser = _currentUser!.copyWith(lastLearningTime: now);
    await _dbService.saveUserProfile(_currentUser!);
    await NotificationService().scheduleDailyReminder(now);
    notifyListeners();
  }

  Future<void> saveUserProfile(UserModel user) async {
    _errorMessage = null;
    try {
      await _dbService.saveUserProfile(user);
      _currentUser = user;
    } catch (e) {
      _errorMessage = 'Failed to save profile.';
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  bool _isRolesLoading = false;
  bool get isRolesLoading => _isRolesLoading;

  Future<void> fetchCareerRoles() async {
    if (_roles.isNotEmpty) return;
    _isRolesLoading = true;
    notifyListeners();
    try {
      _roles = await _dbService.getCareerRoles();
      // Provide default roles if the database is empty
      if (_roles.isEmpty) {
        _roles = [
          // Engineering
          CareerRoleModel(
              id: '1',
              title: 'Mobile App Developer (Flutter)',
              category: 'Engineering',
              iconCode: 0xe597, // phone_android
              requiredSkills: [
                'Dart',
                'Flutter',
                'Widgets & UI Design',
                'Provider',
                'Riverpod',
                'Bloc',
                'REST API',
                'Firebase',
                'Git'
              ],
              description:
                  'Develops high-performance native and cross-platform mobile apps using Flutter.'),
          CareerRoleModel(
              id: '2',
              title: 'Backend Developer (Java / Spring Boot)',
              category: 'Engineering',
              iconCode: 0xe5e1, // storage
              requiredSkills: [
                'Java',
                'Spring Boot',
                'OOP',
                'REST API',
                'Hibernate',
                'JPA',
                'SQL',
                'JWT',
                'Postman'
              ],
              description:
                  'Builds robust and scalable server-side architectures using Java and Spring Boot.'),
          CareerRoleModel(
              id: '3',
              title: 'Java Full Stack Developer',
              category: 'Engineering',
              iconCode: 0xe362, // layers
              requiredSkills: [
                'Java',
                'Spring Boot',
                'HTML',
                'CSS',
                'JavaScript',
                'MySQL',
                'REST API',
                'Git'
              ],
              description:
                  'Handles end-to-end development using Java for backend and web technologies for frontend.'),
          CareerRoleModel(
              id: '4',
              title: 'MERN Stack Developer',
              category: 'Engineering',
              iconCode: 0xe362, // layers
              requiredSkills: [
                'MongoDB',
                'Express.js',
                'React',
                'Node.js',
                'JavaScript',
                'REST API',
                'JSON'
              ],
              description:
                  'Specializes in the MERN stack (MongoDB, Express, React, Node) for modern web development.'),
          CareerRoleModel(
              id: '5',
              title: 'MEAN Stack Developer',
              category: 'Engineering',
              iconCode: 0xe362, // layers
              requiredSkills: [
                'MongoDB',
                'Express.js',
                'Angular',
                'Node.js',
                'JavaScript',
                'REST API'
              ],
              description:
                  'Specializes in the MEAN stack (MongoDB, Express, Angular, Node) for integrated web applications.'),
          CareerRoleModel(
              id: '6',
              title: 'Frontend Developer',
              category: 'Engineering',
              iconCode: 0xe1b1, // code
              requiredSkills: [
                'HTML5',
                'CSS3',
                'JavaScript',
                'React',
                'Angular',
                'Vue',
                'Responsive Design',
                'Git'
              ],
              description:
                  'Creates responsive and interactive user interfaces for web applications.'),
          CareerRoleModel(
              id: '7',
              title: 'Web Developer',
              category: 'Engineering',
              iconCode: 0xe894, // public
              requiredSkills: [
                'HTML',
                'CSS',
                'JavaScript',
                'PHP',
                'Node.js',
                'MySQL',
                'APIs'
              ],
              description:
                  'Develops and maintains websites using various web technologies and CMS platforms.'),

          // Data & AI
          CareerRoleModel(
              id: '8',
              title: 'Data Analyst',
              category: 'Data & AI',
              iconCode: 0xf58c, // bar_chart
              requiredSkills: [
                'Python',
                'SQL',
                'Pandas',
                'NumPy',
                'Excel',
                'Power BI',
                'Tableau'
              ],
              description:
                  'Extracts insights from data to help organizations make informed decisions.'),
          CareerRoleModel(
              id: '9',
              title: 'Data Scientist',
              category: 'Data & AI',
              iconCode: 0xe7f1, // insights
              requiredSkills: [
                'Python',
                'Statistics',
                'Machine Learning',
                'Pandas',
                'Scikit-learn',
                'SQL'
              ],
              description:
                  'Uses advanced analytics and algorithms to solve complex data problems.'),
          CareerRoleModel(
              id: '10',
              title: 'AI / ML Engineer',
              category: 'Data & AI',
              iconCode: 0xf543, // psychology
              requiredSkills: [
                'Python',
                'Linear Algebra',
                'TensorFlow',
                'PyTorch',
                'Deep Learning',
                'Statistics'
              ],
              description:
                  'Develops and deploys intelligent models and machine learning systems.'),

          // Infrastructure & Security
          CareerRoleModel(
              id: '11',
              title: 'Cloud & DevOps Engineer',
              category: 'Infrastructure',
              iconCode: 0xf1a5, // infinity
              requiredSkills: [
                'AWS',
                'Docker',
                'Kubernetes',
                'CI/CD',
                'Linux',
                'Networking',
                'GCP'
              ],
              description:
                  'Automates workflows and manages cloud infrastructure for scale and reliability.'),
          CareerRoleModel(
              id: '12',
              title: 'Cyber Security Analyst',
              category: 'Security',
              iconCode: 0xe58b, // security
              requiredSkills: [
                'Network Security',
                'Ethical Hacking',
                'Firewalls',
                'Cryptography',
                'Linux'
              ],
              description:
                  'Monitors and secures networks and systems against cyber threats.'),

          // Design & QA
          CareerRoleModel(
              id: '13',
              title: 'UI / UX Designer',
              category: 'Design',
              iconCode: 0xe0e6, // brush
              requiredSkills: [
                'Figma',
                'User Research',
                'Prototyping',
                'Design Principles'
              ],
              description:
                  'Designs delightful user experiences and intuitive interfaces for products.'),
          CareerRoleModel(
              id: '14',
              title: 'QA / Software Tester',
              category: 'Quality Assurance',
              iconCode: 0xe86c, // fact_check
              requiredSkills: [
                'Manual Testing',
                'Automation',
                'Selenium',
                'Test Cases'
              ],
              description:
                  'Ensures product quality through rigorous testing and automation.'),

          // Product & Management
          CareerRoleModel(
              id: '15',
              title: 'Product Manager',
              category: 'Management',
              iconCode: 0xf603, // assignment_ind
              requiredSkills: [
                'Strategy',
                'Roadmapping',
                'Agile',
                'Market Analysis'
              ],
              description:
                  'Guides the development of a product from conception to launch.'),

          // Mobile Specialized
          CareerRoleModel(
              id: '16',
              title: 'Android Developer (Kotlin)',
              category: 'Engineering',
              iconCode: 0xe597, // phone_android
              requiredSkills: [
                'Kotlin',
                'Android SDK',
                'Jetpack Compose',
                'Retrofit'
              ],
              description:
                  'Builds native high-performance Android applications using Kotlin.'),
          CareerRoleModel(
              id: '17',
              title: 'iOS Developer (Swift)',
              category: 'Engineering',
              iconCode: 0xe30c, // phone_iphone
              requiredSkills: ['Swift', 'SwiftUI', 'Xcode', 'Core Data'],
              description:
                  'Develops elegant and responsive native iOS applications using Swift.'),

          // More specialized Engineering
          CareerRoleModel(
              id: '18',
              title: 'Blockchain Developer',
              category: 'Engineering',
              iconCode:
                  0xeaf0, // linked_camera (best fit for link/chain in available codes often) or 0xe23a
              requiredSkills: [
                'Solidity',
                'Ethereum',
                'Smart Contracts',
                'Web3.js'
              ],
              description:
                  'Designs and implements decentralized applications and smart contracts.'),

          // Infrastructure Extra
          CareerRoleModel(
              id: '19',
              title: 'Data Engineer',
              category: 'Data & AI',
              iconCode: 0xf833, // settings_input_component
              requiredSkills: [
                'Apache Spark',
                'Kafka',
                'Hadoop',
                'ETL Pipelines'
              ],
              description:
                  'Builds systems to collect and process large-scale data for analysis.'),
          CareerRoleModel(
              id: '20',
              title: 'Cloud Architect',
              category: 'Infrastructure',
              iconCode: 0xe18a, // cloud
              requiredSkills: ['AWS', 'Azure', 'Terraform', 'Serverless'],
              description:
                  'Designs and oversees the implementation of enterprise cloud strategies.'),

          // ECE Department Roles
          CareerRoleModel(
              id: '21',
              title: 'Embedded Systems Engineer',
              category: 'ECE',
              iconCode: 0xe30a, // memory
              requiredSkills: [
                'C',
                'C++',
                'Microcontrollers',
                'ARM Cortex',
                'RTOS',
                'Embedded Linux',
                'I2C',
                'SPI',
                'UART',
                'Debugging Tools'
              ],
              description:
                  'Designs and develops embedded systems for real-time applications using microcontrollers and processors.'),
          CareerRoleModel(
              id: '22',
              title: 'VLSI Design Engineer',
              category: 'ECE',
              iconCode: 0xe322, // developer_board
              requiredSkills: [
                'Verilog',
                'VHDL',
                'Digital Design',
                'Cadence',
                'Synopsis',
                'ASIC Design',
                'FPGA',
                'Timing Analysis',
                'RTL Design'
              ],
              description:
                  'Designs and verifies integrated circuits and chip architectures using HDL languages.'),
          CareerRoleModel(
              id: '23',
              title: 'IoT Engineer',
              category: 'ECE',
              iconCode: 0xe1b0, // devices_other
              requiredSkills: [
                'Arduino',
                'Raspberry Pi',
                'ESP32',
                'MQTT',
                'CoAP',
                'Sensors',
                'AWS IoT',
                'Azure IoT',
                'Python',
                'C/C++'
              ],
              description:
                  'Develops Internet of Things solutions connecting sensors, devices, and cloud platforms.'),
          CareerRoleModel(
              id: '24',
              title: 'Signal Processing Engineer',
              category: 'ECE',
              iconCode: 0xe6fc, // graphic_eq
              requiredSkills: [
                'DSP',
                'MATLAB',
                'Python',
                'Fourier Analysis',
                'Filtering',
                'Image Processing',
                'Audio Processing',
                'NumPy',
                'SciPy'
              ],
              description:
                  'Analyzes and processes signals for communications, audio, video, and sensor applications.'),
          CareerRoleModel(
              id: '25',
              title: 'RF/Wireless Engineer',
              category: 'ECE',
              iconCode: 0xe1b8, // wifi
              requiredSkills: [
                'RF Circuit Design',
                'Antenna Design',
                'Wireless Protocols',
                'Spectrum Analysis',
                'Bluetooth',
                'Wi-Fi',
                'LoRa',
                'Zigbee',
                'ADS',
                'CST'
              ],
              description:
                  'Designs and optimizes RF circuits, antennas, and wireless communication systems.'),
          CareerRoleModel(
              id: '26',
              title: 'Network Engineer',
              category: 'ECE',
              iconCode: 0xe8f4, // router
              requiredSkills: [
                'TCP/IP',
                'Routing',
                'Switching',
                'Cisco',
                'Network Security',
                'VLAN',
                'BGP',
                'OSPF',
                'Firewall',
                'VPN'
              ],
              description:
                  'Designs, implements, and maintains computer networks and communication infrastructure.'),
          CareerRoleModel(
              id: '27',
              title: 'Telecommunications Engineer',
              category: 'ECE',
              iconCode: 0xe0b0, // cell_tower
              requiredSkills: [
                '4G/5G',
                'Optical Fiber',
                'Modulation Techniques',
                'Telecom Protocols',
                'Network Planning',
                'LTE',
                'GSM',
                'Signal Analysis',
                'RF Planning'
              ],
              description:
                  'Develops and maintains telecommunications networks and mobile communication systems.'),
          CareerRoleModel(
              id: '28',
              title: 'Hardware Design Engineer',
              category: 'ECE',
              iconCode: 0xe30b, // settings_input_component
              requiredSkills: [
                'PCB Design',
                'Altium Designer',
                'Eagle',
                'KiCad',
                'Circuit Simulation',
                'SPICE',
                'Analog Design',
                'Power Electronics',
                'EMI/EMC'
              ],
              description:
                  'Designs printed circuit boards and electronic hardware for various applications.'),
          CareerRoleModel(
              id: '29',
              title: 'Firmware Engineer',
              category: 'ECE',
              iconCode: 0xe868, // code
              requiredSkills: [
                'Embedded C',
                'C++',
                'Bootloaders',
                'Device Drivers',
                'HAL',
                'Debugging Tools',
                'JTAG',
                'Flash Memory',
                'Low-Level Programming'
              ],
              description:
                  'Develops low-level software that directly controls hardware components and devices.'),
          CareerRoleModel(
              id: '30',
              title: 'Robotics Engineer',
              category: 'ECE',
              iconCode: 0xe99a, // precision_manufacturing
              requiredSkills: [
                'ROS',
                'Python',
                'C++',
                'Kinematics',
                'Control Systems',
                'Sensors',
                'Actuators',
                'Computer Vision',
                'Path Planning',
                'SLAM'
              ],
              description:
                  'Designs and programs robotic systems integrating mechanical, electrical, and software components.'),

          // Mechanical Engineering
          CareerRoleModel(
              id: '31',
              title: 'Mechanical Design Engineer',
              category: 'Mechanical',
              iconCode: 0xe869, // settings
              requiredSkills: [
                'CAD',
                'SolidWorks',
                'AutoCAD',
                'CATIA',
                'FEA',
                'GD&T',
                'Mechanical Design',
                'Product Design',
                'Manufacturing Processes'
              ],
              description:
                  'Designs mechanical components and systems using CAD tools and engineering principles.'),
          CareerRoleModel(
              id: '32',
              title: 'CAD/CAM Engineer',
              category: 'Mechanical',
              iconCode: 0xe3ae, // view_in_ar
              requiredSkills: [
                'CAD',
                'CAM',
                'CNC Programming',
                'SolidWorks',
                'Mastercam',
                '3D Modeling',
                'Toolpath Generation',
                'G-Code'
              ],
              description:
                  'Develops computer-aided designs and manufacturing processes for production.'),
          CareerRoleModel(
              id: '33',
              title: 'Thermal Engineer',
              category: 'Mechanical',
              iconCode: 0xe1ff, // whatshot
              requiredSkills: [
                'Heat Transfer',
                'Thermodynamics',
                'CFD',
                'ANSYS Fluent',
                'Thermal Analysis',
                'HVAC',
                'Cooling Systems'
              ],
              description:
                  'Analyzes and optimizes thermal performance of systems and components.'),
          CareerRoleModel(
              id: '34',
              title: 'Manufacturing Engineer',
              category: 'Mechanical',
              iconCode: 0xe8e3, // precision_manufacturing
              requiredSkills: [
                'Lean Manufacturing',
                'Six Sigma',
                'Process Optimization',
                'Quality Control',
                'Production Planning',
                'CNC',
                'Automation'
              ],
              description:
                  'Optimizes manufacturing processes and production systems for efficiency.'),
          CareerRoleModel(
              id: '35',
              title: 'Automotive Engineer',
              category: 'Mechanical',
              iconCode: 0xe531, // directions_car
              requiredSkills: [
                'Vehicle Dynamics',
                'Powertrain',
                'CAD',
                'Automotive Systems',
                'Engine Design',
                'MATLAB',
                'Testing & Validation'
              ],
              description:
                  'Designs and develops automotive systems and vehicle components.'),

          // Civil Engineering
          CareerRoleModel(
              id: '36',
              title: 'Structural Engineer',
              category: 'Civil',
              iconCode: 0xe0c8, // domain
              requiredSkills: [
                'Structural Analysis',
                'AutoCAD',
                'STAAD Pro',
                'Concrete Design',
                'Steel Design',
                'Building Codes',
                'Seismic Design'
              ],
              description:
                  'Designs and analyzes structural systems for buildings and infrastructure.'),
          CareerRoleModel(
              id: '37',
              title: 'Construction Manager',
              category: 'Civil',
              iconCode: 0xe869, // construction
              requiredSkills: [
                'Project Management',
                'Construction Planning',
                'Cost Estimation',
                'Site Management',
                'Safety Management',
                'Scheduling',
                'Contract Management'
              ],
              description:
                  'Manages construction projects from planning to completion.'),
          CareerRoleModel(
              id: '38',
              title: 'Transportation Engineer',
              category: 'Civil',
              iconCode: 0xe558, // traffic
              requiredSkills: [
                'Traffic Engineering',
                'Highway Design',
                'Transportation Planning',
                'AutoCAD Civil 3D',
                'Traffic Simulation',
                'Road Safety'
              ],
              description:
                  'Plans and designs transportation systems and infrastructure.'),
          CareerRoleModel(
              id: '39',
              title: 'Geotechnical Engineer',
              category: 'Civil',
              iconCode: 0xe55b, // terrain
              requiredSkills: [
                'Soil Mechanics',
                'Foundation Design',
                'Slope Stability',
                'Site Investigation',
                'Geotechnical Analysis',
                'PLAXIS'
              ],
              description:
                  'Analyzes soil and rock behavior for foundation and earthwork design.'),

          // Chemical Engineering
          CareerRoleModel(
              id: '40',
              title: 'Process Engineer',
              category: 'Chemical',
              iconCode: 0xe8e3, // factory
              requiredSkills: [
                'Process Design',
                'Chemical Engineering',
                'ASPEN Plus',
                'Process Simulation',
                'P&ID',
                'Process Optimization',
                'Safety Analysis'
              ],
              description:
                  'Designs and optimizes chemical processes and manufacturing operations.'),
          CareerRoleModel(
              id: '41',
              title: 'Chemical Plant Engineer',
              category: 'Chemical',
              iconCode: 0xe0af, // business
              requiredSkills: [
                'Plant Operations',
                'Process Control',
                'Chemical Safety',
                'Equipment Design',
                'Troubleshooting',
                'Quality Assurance'
              ],
              description:
                  'Manages operations and maintenance of chemical processing plants.'),
          CareerRoleModel(
              id: '42',
              title: 'Petroleum Engineer',
              category: 'Chemical',
              iconCode: 0xe8e3, // oil_barrel
              requiredSkills: [
                'Reservoir Engineering',
                'Drilling Engineering',
                'Production Engineering',
                'Well Testing',
                'Petroleum Geology',
                'Simulation Software'
              ],
              description:
                  'Develops methods for extracting oil and gas from underground reservoirs.'),

          // Electrical Engineering
          CareerRoleModel(
              id: '43',
              title: 'Power Systems Engineer',
              category: 'Electrical',
              iconCode: 0xe1e0, // power
              requiredSkills: [
                'Power Systems',
                'Electrical Machines',
                'Protection Systems',
                'ETAP',
                'Power Electronics',
                'Grid Integration',
                'Transmission & Distribution'
              ],
              description:
                  'Designs and analyzes electrical power generation and distribution systems.'),
          CareerRoleModel(
              id: '44',
              title: 'Control Systems Engineer',
              category: 'Electrical',
              iconCode: 0xe8b8, // tune
              requiredSkills: [
                'Control Theory',
                'PLC Programming',
                'SCADA',
                'Automation',
                'PID Control',
                'MATLAB Simulink',
                'Industrial Control'
              ],
              description:
                  'Designs automated control systems for industrial processes and machinery.'),
          CareerRoleModel(
              id: '45',
              title: 'Electrical Design Engineer',
              category: 'Electrical',
              iconCode: 0xe0e6, // electrical_services
              requiredSkills: [
                'Electrical Design',
                'AutoCAD Electrical',
                'Circuit Design',
                'Wiring Diagrams',
                'Electrical Codes',
                'Load Calculations',
                'Panel Design'
              ],
              description:
                  'Designs electrical systems and components for buildings and facilities.'),
          CareerRoleModel(
              id: '46',
              title: 'Renewable Energy Engineer',
              category: 'Electrical',
              iconCode: 0xe90f, // wb_sunny
              requiredSkills: [
                'Solar Energy',
                'Wind Energy',
                'PV Systems',
                'Energy Storage',
                'Grid Integration',
                'PVsyst',
                'Renewable Technologies'
              ],
              description:
                  'Develops renewable energy systems and sustainable power solutions.'),

          // Biomedical Engineering
          CareerRoleModel(
              id: '47',
              title: 'Biomedical Device Engineer',
              category: 'Biomedical',
              iconCode: 0xe1af, // medical_services
              requiredSkills: [
                'Medical Devices',
                'Biomedical Instrumentation',
                'FDA Regulations',
                'CAD',
                'Prototyping',
                'Testing & Validation',
                'Biomaterials'
              ],
              description:
                  'Designs and develops medical devices and diagnostic equipment.'),
          CareerRoleModel(
              id: '48',
              title: 'Clinical Engineer',
              category: 'Biomedical',
              iconCode: 0xe1b1, // local_hospital
              requiredSkills: [
                'Medical Equipment',
                'Healthcare Technology',
                'Equipment Maintenance',
                'Safety Standards',
                'Hospital Systems',
                'Troubleshooting'
              ],
              description:
                  'Manages and maintains medical equipment in healthcare facilities.'),
          CareerRoleModel(
              id: '49',
              title: 'Biomechanics Engineer',
              category: 'Biomedical',
              iconCode: 0xe8ce, // accessibility
              requiredSkills: [
                'Biomechanics',
                'Gait Analysis',
                'Prosthetics',
                'Orthotics',
                'Motion Capture',
                'FEA',
                'Human Anatomy'
              ],
              description:
                  'Applies mechanical principles to biological systems and medical applications.'),

          // Aerospace Engineering
          CareerRoleModel(
              id: '50',
              title: 'Aerospace Design Engineer',
              category: 'Aerospace',
              iconCode: 0xe539, // flight
              requiredSkills: [
                'Aerodynamics',
                'Aircraft Design',
                'CATIA',
                'CFD',
                'Structural Analysis',
                'Flight Mechanics',
                'Composite Materials'
              ],
              description:
                  'Designs aircraft and spacecraft structures and systems.'),
          CareerRoleModel(
              id: '51',
              title: 'Avionics Engineer',
              category: 'Aerospace',
              iconCode: 0xe1b8, // flight_takeoff
              requiredSkills: [
                'Avionics Systems',
                'Navigation Systems',
                'Flight Control',
                'Embedded Systems',
                'DO-178C',
                'Communication Systems',
                'Testing'
              ],
              description:
                  'Develops electronic systems for aircraft and spacecraft.'),
          CareerRoleModel(
              id: '52',
              title: 'Propulsion Engineer',
              category: 'Aerospace',
              iconCode: 0xe558, // rocket_launch
              requiredSkills: [
                'Propulsion Systems',
                'Thermodynamics',
                'Combustion',
                'Rocket Engines',
                'CFD',
                'Gas Dynamics',
                'Performance Analysis'
              ],
              description:
                  'Designs and analyzes propulsion systems for aerospace vehicles.'),

          // Environmental Engineering
          CareerRoleModel(
              id: '53',
              title: 'Environmental Engineer',
              category: 'Environmental',
              iconCode: 0xe8b5, // eco
              requiredSkills: [
                'Environmental Science',
                'Water Treatment',
                'Air Quality',
                'Waste Management',
                'Environmental Regulations',
                'Sustainability',
                'Impact Assessment'
              ],
              description:
                  'Develops solutions for environmental protection and sustainability.'),
          CareerRoleModel(
              id: '54',
              title: 'Water Resources Engineer',
              category: 'Environmental',
              iconCode: 0xe798, // water_drop
              requiredSkills: [
                'Hydrology',
                'Water Supply',
                'Drainage Design',
                'HEC-RAS',
                'Watershed Management',
                'Hydraulic Modeling',
                'Irrigation'
              ],
              description:
                  'Manages water resources and designs water supply systems.'),

          // Industrial Engineering
          CareerRoleModel(
              id: '55',
              title: 'Industrial Engineer',
              category: 'Industrial',
              iconCode: 0xe8e3, // inventory
              requiredSkills: [
                'Process Improvement',
                'Operations Research',
                'Supply Chain',
                'Lean Six Sigma',
                'Ergonomics',
                'Simulation',
                'Optimization'
              ],
              description:
                  'Optimizes complex processes and systems for efficiency.'),
          CareerRoleModel(
              id: '56',
              title: 'Quality Engineer',
              category: 'Industrial',
              iconCode: 0xe86c, // verified
              requiredSkills: [
                'Quality Management',
                'Six Sigma',
                'Statistical Analysis',
                'ISO Standards',
                'Root Cause Analysis',
                'Quality Control',
                'Auditing'
              ],
              description:
                  'Ensures product quality through systematic testing and analysis.'),
          CareerRoleModel(
              id: '57',
              title: 'Supply Chain Engineer',
              category: 'Industrial',
              iconCode: 0xe558, // local_shipping
              requiredSkills: [
                'Supply Chain Management',
                'Logistics',
                'Inventory Management',
                'ERP Systems',
                'Demand Forecasting',
                'Optimization',
                'Analytics'
              ],
              description:
                  'Optimizes supply chain operations and logistics networks.'),

          // Other Engineering Disciplines
          CareerRoleModel(
              id: '58',
              title: 'Safety Engineer',
              category: 'Safety',
              iconCode: 0xe86e, // health_and_safety
              requiredSkills: [
                'Safety Management',
                'Risk Assessment',
                'OSHA Standards',
                'Hazard Analysis',
                'Safety Audits',
                'Incident Investigation',
                'Safety Training'
              ],
              description:
                  'Ensures workplace safety and compliance with regulations.'),
          CareerRoleModel(
              id: '59',
              title: 'Materials Engineer',
              category: 'Materials',
              iconCode: 0xe30b, // science
              requiredSkills: [
                'Materials Science',
                'Metallurgy',
                'Material Testing',
                'Failure Analysis',
                'Composites',
                'Polymers',
                'Characterization'
              ],
              description:
                  'Develops and tests materials for engineering applications.'),
          CareerRoleModel(
              id: '60',
              title: 'Instrumentation Engineer',
              category: 'Instrumentation',
              iconCode: 0xe1b8, // speed
              requiredSkills: [
                'Instrumentation',
                'Process Control',
                'Sensors',
                'Calibration',
                'DCS',
                'Field Instruments',
                'Loop Testing'
              ],
              description:
                  'Designs and maintains measurement and control instruments.'),
          CareerRoleModel(
              id: '61',
              title: 'Mining Engineer',
              category: 'Mining',
              iconCode: 0xe8e3, // construction
              requiredSkills: [
                'Mining Operations',
                'Mineral Processing',
                'Mine Planning',
                'Geology',
                'Blasting',
                'Safety',
                'Surveying'
              ],
              description:
                  'Plans and manages extraction of minerals and resources.'),
          CareerRoleModel(
              id: '62',
              title: 'Biotechnology Engineer',
              category: 'Biotechnology',
              iconCode: 0xe30b, // biotech
              requiredSkills: [
                'Biotechnology',
                'Genetic Engineering',
                'Bioreactors',
                'Fermentation',
                'Molecular Biology',
                'Bioprocessing',
                'Lab Techniques'
              ],
              description:
                  'Applies biological processes to develop products and technologies.'),
          CareerRoleModel(
              id: '63',
              title: 'Textile Engineer',
              category: 'Textile',
              iconCode: 0xe8e3, // checkroom
              requiredSkills: [
                'Textile Technology',
                'Fabric Design',
                'Dyeing & Printing',
                'Quality Control',
                'Production Planning',
                'Textile Testing',
                'Garment Manufacturing'
              ],
              description:
                  'Develops and improves textile manufacturing processes.'),
          CareerRoleModel(
              id: '64',
              title: 'Agricultural Engineer',
              category: 'Agricultural',
              iconCode: 0xe558, // agriculture
              requiredSkills: [
                'Agricultural Systems',
                'Irrigation',
                'Farm Machinery',
                'Soil Science',
                'Crop Management',
                'Precision Agriculture',
                'Sustainability'
              ],
              description:
                  'Designs agricultural equipment and farming systems.'),
          CareerRoleModel(
              id: '65',
              title: 'Food Process Engineer',
              category: 'Food Technology',
              iconCode: 0xe558, // restaurant
              requiredSkills: [
                'Food Processing',
                'Food Safety',
                'HACCP',
                'Quality Control',
                'Process Design',
                'Packaging',
                'Preservation Techniques'
              ],
              description:
                  'Develops and optimizes food processing and preservation methods.'),
        ];
      }
    } catch (e) {
      print('ERROR: Failed to fetch roles: $e');
    } finally {
      _isRolesLoading = false;
      notifyListeners();
    }
  }

  void selectCareerGoal(String goal) {
    if (_currentUser != null) {
      final updatedUser = UserModel(
        uid: _currentUser!.uid,
        email: _currentUser!.email,
        displayName: _currentUser!.displayName,
        photoUrl: _currentUser!.photoUrl,
        education: _currentUser!.education,
        department: _currentUser!.department,
        careerGoal: goal,
        manualSkills: _currentUser!.manualSkills,
      );
      saveUserProfile(updatedUser);
    }
  }

  void updateUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }
}

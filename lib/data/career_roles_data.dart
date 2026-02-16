import '../models/career_role_model.dart';

List<CareerRoleModel> getInitialCareerRoles() {
  return [
    // =========================================================================
    // CSE / IT: Technology Specific Roles
    // =========================================================================

    // --- Backend Development ---
    CareerRoleModel(
        id: 'cse_bend_java',
        title: 'Backend Developer (Java/Spring)',
        category: 'CSE/IT',
        iconCode: 0xe5e1,
        requiredSkills: [
          // Basic
          'Core Java',
          'OOP Fundamentals',
          'Data Structures & Algorithms',
          'SQL & Relational Databases',
          // Existing / Intermediate
          'Java',
          'Spring Boot',
          'Hibernate',
          'Microservices',
          'REST',
          // Advanced
          'Spring Security',
          'Spring Data JPA',
          'API Design & Documentation (OpenAPI/Swagger)',
          'Caching (Redis)',
          'Message Queues (Kafka/RabbitMQ)',
          'Docker',
          'Kubernetes',
          'CI/CD Pipelines',
          'Cloud Deployment (AWS/Azure/GCP)',
          'Monitoring & Logging (ELK/Prometheus/Grafana)'
        ],
        description:
            'Builds scalable enterprise backends using Java ecosystem.'),
    CareerRoleModel(
        id: 'cse_bend_python',
        title: 'Backend Developer (Python)',
        category: 'CSE/IT',
        iconCode: 0xe5e1,
        requiredSkills: [
          // Basic
          'Core Python',
          'OOP Fundamentals',
          'Data Structures & Algorithms',
          'Version Control (Git)',
          'SQL Fundamentals',
          // Existing / Intermediate
          'Python',
          'Django',
          'FastAPI',
          'Flask',
          'PostgreSQL',
          // Advanced
          'Asynchronous Programming (asyncio)',
          'REST API Design',
          'Authentication & Authorization (JWT/OAuth2)',
          'ORMs (Django ORM/SQLAlchemy)',
          'Testing (PyTest/UnitTest)',
          'Docker',
          'CI/CD Pipelines',
          'Caching (Redis)',
          'Celery & Task Queues',
          'API Documentation (OpenAPI/Swagger)',
          'Cloud Deployment (AWS/Azure/GCP)'
        ],
        description:
            'Develops rapid and efficient backends using Python frameworks.'),
    CareerRoleModel(
        id: 'cse_bend_node',
        title: 'Backend Developer (Node.js)',
        category: 'CSE/IT',
        iconCode: 0xe5e1,
        requiredSkills: [
          // Basic
          'Core JavaScript (ES6+)',
          'Asynchronous Programming (Callbacks/Promises/Async-Await)',
          'HTTP & REST Fundamentals',
          // Existing / Intermediate
          'Node.js',
          'Express',
          'NestJS',
          'MongoDB',
          'TypeScript',
          // Advanced
          'API Design & Versioning',
          'Authentication & Authorization (JWT/OAuth2)',
          'Database Design (NoSQL & SQL)',
          'ORM/ODM (Mongoose/Prisma/TypeORM)',
          'Caching (Redis)',
          'Message Queues (Kafka/RabbitMQ)',
          'Microservices Architecture',
          'Testing (Jest/Supertest)',
          'Docker',
          'Kubernetes',
          'CI/CD Pipelines',
          'Monitoring & Logging (Winston/ELK/Prometheus)'
        ],
        description:
            'Builds high-performance I/O intensive backends with Node.js.'),
    CareerRoleModel(
        id: 'cse_bend_dotnet',
        title: 'Backend Developer (.NET)',
        category: 'CSE/IT',
        iconCode: 0xe5e1,
        requiredSkills: [
          // Basic
          'C# Fundamentals',
          'OOP & SOLID Principles',
          'Data Structures & Algorithms',
          'SQL Fundamentals',
          // Existing / Intermediate
          'C#',
          '.NET Core',
          'ASP.NET',
          'SQL Server',
          'Azure',
          // Advanced
          'Entity Framework Core',
          'ASP.NET Web API',
          'Authentication & Authorization (Identity/JWT/OAuth2)',
          'REST API Design & Documentation',
          'Design Patterns',
          'Microservices with .NET',
          'Docker',
          'Kubernetes',
          'CI/CD Pipelines (Azure DevOps/GitHub Actions)',
          'Cloud Native Development on Azure',
          'Monitoring & Logging (App Insights/Serilog)'
        ],
        description:
            'Develops robust enterprise solutions using the Microsoft stack.'),
    CareerRoleModel(
        id: 'cse_bend_go',
        title: 'Backend Developer (Golang)',
        category: 'CSE/IT',
        iconCode: 0xe5e1,
        requiredSkills: [
          // Basic
          'Programming Fundamentals',
          'Data Structures & Algorithms',
          'Linux & Command Line',
          // Existing / Intermediate
          'Go',
          'gRPC',
          'Microservices',
          'Concurrency',
          'Docker',
          // Advanced
          'Go Routines & Channels',
          'REST & gRPC API Design',
          'Database Access (SQL/NoSQL)',
          'Distributed Systems Basics',
          'Message Queues (Kafka/NATS/RabbitMQ)',
          'Performance Profiling & Optimization',
          'Kubernetes',
          'Cloud Native Development (AWS/GCP/Azure)',
          'Observability (Prometheus/Grafana/OpenTelemetry)'
        ],
        description: 'Builds highly concurrent and fast backend services.'),
    CareerRoleModel(
        id: 'cse_bend_php',
        title: 'Backend Developer (PHP/Laravel)',
        category: 'CSE/IT',
        iconCode: 0xe5e1,
        requiredSkills: [
          // Basic
          'Core PHP',
          'Programming Fundamentals',
          'HTML/CSS Basics',
          'SQL Fundamentals',
          // Existing / Intermediate
          'PHP',
          'Laravel',
          'MySQL',
          'Composer',
          'API Development',
          // Advanced
          'REST API Design & Authentication (JWT/OAuth2)',
          'Eloquent ORM',
          'Blade Templating',
          'Queues & Jobs',
          'Caching (Redis/Memcached)',
          'Testing (PHPUnit/Pest)',
          'Security Best Practices (OWASP)',
          'Docker',
          'CI/CD Pipelines',
          'Cloud Deployment (AWS/Forge/Vapor)'
        ],
        description: 'Develops web applications using modern PHP frameworks.'),

    // --- Frontend Development ---
    CareerRoleModel(
        id: 'cse_fend_react',
        title: 'Frontend Developer (React)',
        category: 'CSE/IT',
        iconCode: 0xe1b1,
        requiredSkills: [
          // Basic
          'HTML5',
          'CSS3',
          'Responsive Design',
          'Core JavaScript (ES6+)',
          // Existing / Intermediate
          'React',
          'Redux',
          'JavaScript',
          'HTML5/CSS',
          'Webpack',
          // Advanced
          'TypeScript',
          'React Hooks & Context',
          'State Management (Redux Toolkit/Zustand)',
          'Routing (React Router)',
          'API Integration (REST/GraphQL)',
          'Testing (Jest/React Testing Library)',
          'Performance Optimization',
          'Accessibility (a11y)',
          'CSS-in-JS (Styled Components/Emotion)',
          'Build & Bundling (Vite/Parcel)',
          'CI/CD & Deployment (Vercel/Netlify/AWS)'
        ],
        description: 'Builds dynamic UIs using the React library.'),
    CareerRoleModel(
        id: 'cse_fend_angular',
        title: 'Frontend Developer (Angular)',
        category: 'CSE/IT',
        iconCode: 0xe1b1,
        requiredSkills: [
          // Basic
          'HTML5',
          'CSS3/SCSS',
          'Core JavaScript (ES6+)',
          // Existing / Intermediate
          'Angular',
          'TypeScript',
          'RxJS',
          'HTML/SCSS',
          'Ngrx',
          // Advanced
          'Angular CLI',
          'Component Architecture & Modules',
          'Reactive Forms & Template Forms',
          'Routing & Guards',
          'State Management (NgRx/Akita)',
          'REST API Integration',
          'Testing (Jasmine/Karma)',
          'Performance Tuning & Lazy Loading',
          'Accessibility (a11y)',
          'Angular Material',
          'CI/CD & Deployment'
        ],
        description:
            'Develops enterprise-grade single page applications with Angular.'),
    CareerRoleModel(
        id: 'cse_fend_vue',
        title: 'Frontend Developer (Vue.js)',
        category: 'CSE/IT',
        iconCode: 0xe1b1,
        requiredSkills: [
          // Basic
          'HTML5',
          'CSS3',
          'Core JavaScript (ES6+)',
          // Existing / Intermediate
          'Vue.js',
          'Vuex',
          'JavaScript',
          'Nuxt.js',
          'Tailwind',
          // Advanced
          'Composition API',
          'Vue Router',
          'State Management (Pinia/Vuex)',
          'SSR with Nuxt',
          'REST/GraphQL API Integration',
          'Testing (Vitest/Jest/Cypress)',
          'Component Libraries (Vuetify/Element Plus)',
          'Performance Optimization',
          'Accessibility (a11y)',
          'Build Tooling (Vite/Webpack)'
        ],
        description:
            'Creates flexible and lightweight user interfaces with Vue.'),
    CareerRoleModel(
        id: 'cse_fend_next',
        title: 'Frontend Developer (Next.js)',
        category: 'CSE/IT',
        iconCode: 0xe1b1,
        requiredSkills: [
          // Basic
          'HTML5',
          'CSS3',
          'Core JavaScript (ES6+)',
          // Existing / Intermediate
          'Next.js',
          'React',
          'SSR',
          'TypeScript',
          'Vercel',
          // Advanced
          'File-based Routing & App Router',
          'Server Components',
          'API Routes',
          'Incremental Static Regeneration (ISR)',
          'SEO Fundamentals',
          'Authentication (NextAuth/Auth0)',
          'Performance Optimization & Caching',
          'Styling (Tailwind/CSS Modules)',
          'Testing (Jest/React Testing Library)',
          'Deployment & Edge Functions'
        ],
        description:
            'Builds SEO-friendly and performant web apps with Next.js.'),

    // --- Mobile Development ---
    CareerRoleModel(
        id: 'cse_mob_flutter',
        title: 'Mobile Developer (Flutter)',
        category: 'CSE/IT',
        iconCode: 0xe597,
        requiredSkills: [
          // Basic
          'Programming Fundamentals',
          'OOP Concepts',
          'Mobile Design Basics',
          // Existing / Intermediate
          'Dart',
          'Flutter',
          'Bloc',
          'Firebase',
          'Mobile UI',
          // Advanced
          'State Management (Bloc/Provider/GetX/Riverpod)',
          'Navigation & Deep Linking',
          'REST API Integration',
          'Offline Storage (SQLite/Hive)',
          'Animations & Custom Widgets',
          'Platform Channels (Native Integration)',
          'Testing (Unit/Widget/Integration)',
          'App Store & Play Store Deployment',
          'Performance Optimization',
          'CI/CD for Mobile (Codemagic/GitHub Actions)'
        ],
        description: 'Creates cross-platform apps from a single codebase.'),
    CareerRoleModel(
        id: 'cse_mob_rn',
        title: 'Mobile Developer (React Native)',
        category: 'CSE/IT',
        iconCode: 0xe597,
        requiredSkills: [
          // Basic
          'JavaScript Fundamentals',
          'HTML/CSS Basics',
          // Existing / Intermediate
          'React Native',
          'JavaScript',
          'Redux',
          'Native Modules',
          // Advanced
          'React Hooks',
          'Navigation (React Navigation)',
          'State Management (Redux/MobX/Zustand)',
          'REST API Integration',
          'Offline Storage (AsyncStorage/SQLite)',
          'Bridge & Native Modules (Android/iOS)',
          'Testing (Jest/Detox)',
          'App Store & Play Store Deployment',
          'Performance Optimization & Profiling'
        ],
        description: 'Builds mobile apps using React and JavaScript.'),
    CareerRoleModel(
        id: 'cse_mob_ios',
        title: 'iOS Developer (Swift)',
        category: 'CSE/IT',
        iconCode: 0xe30c,
        requiredSkills: [
          // Basic
          'Programming Fundamentals',
          'OOP Concepts',
          // Existing / Intermediate
          'Swift',
          'SwiftUI',
          'UIKit',
          'Xcode',
          'CoreData',
          // Advanced
          'Auto Layout & Storyboards',
          'Networking (URLSession/Alamofire)',
          'Concurrency (GCD/Async-Await)',
          'Architectures (MVC/MVVM/Clean)',
          'Unit & UI Testing (XCTest)',
          'Push Notifications',
          'App Store Deployment & Certificates',
          'Performance & Memory Profiling (Instruments)'
        ],
        description: 'Builds native iOS applications for Apple ecosystem.'),
    CareerRoleModel(
        id: 'cse_mob_android',
        title: 'Android Developer (Kotlin)',
        category: 'CSE/IT',
        iconCode: 0xe597,
        requiredSkills: [
          // Basic
          'Programming Fundamentals',
          'OOP Concepts',
          // Existing / Intermediate
          'Kotlin',
          'Jetpack Compose',
          'Coroutines',
          'Android SDK',
          // Advanced
          'Android Jetpack (ViewModel/LiveData/Room)',
          'Architectures (MVVM/MVI/Clean)',
          'REST API Integration (Retrofit/OkHttp)',
          'Navigation Component',
          'Dependency Injection (Hilt/Koin)',
          'Testing (JUnit/Espresso)',
          'Play Store Deployment',
          'Performance Optimization & Profiling'
        ],
        description: 'Develops native Android applications efficiently.'),

    // --- Full Stack ---
    CareerRoleModel(
        id: 'cse_full_mern',
        title: 'Full Stack (MERN)',
        category: 'CSE/IT',
        iconCode: 0xe362,
        requiredSkills: ['MongoDB', 'Express', 'React', 'Node.js', 'AWS'],
        description: 'Handles full stack JavaScript web development.'),
    CareerRoleModel(
        id: 'cse_full_mean',
        title: 'Full Stack (MEAN)',
        category: 'CSE/IT',
        iconCode: 0xe362,
        requiredSkills: [
          'MongoDB',
          'Express',
          'Angular',
          'Node.js',
          'TypeScript'
        ],
        description: 'Builds full stack apps with Angular and Node.'),
    CareerRoleModel(
        id: 'cse_full_java',
        title: 'Full Stack (Java + React)',
        category: 'CSE/IT',
        iconCode: 0xe362,
        requiredSkills: ['Java', 'Spring Boot', 'React', 'SQL', 'REST'],
        description:
            'Combines robust Java backend with modern React frontend.'),
    CareerRoleModel(
        id: 'cse_full_dotnet',
        title: 'Full Stack (.NET + Angular)',
        category: 'CSE/IT',
        iconCode: 0xe362,
        requiredSkills: ['C#', '.NET', 'Angular', 'SQL Server', 'Azure'],
        description: 'Full stack development within the Microsoft ecosystem.'),

    // --- Other CSE Roles ---
    CareerRoleModel(
        id: 'cse_devops_aws',
        title: 'DevOps Engineer (AWS)',
        category: 'CSE/IT',
        iconCode: 0xf1a5,
        requiredSkills: ['AWS', 'Terraform', 'Docker', 'Kubernetes', 'CI/CD'],
        description: 'Manages cloud infrastructure on Amazon Web Services.'),
    CareerRoleModel(
        id: 'cse_cyber_pen',
        title: 'Penetration Tester',
        category: 'CSE/IT',
        iconCode: 0xe58b,
        requiredSkills: [
          'Kali Linux',
          'Metasploit',
          'Burp Suite',
          'Python',
          'Networking'
        ],
        description:
            'Simulates cyber attacks to identify security weaknesses.'),

    // =========================================================================
    // ECE (Electronics & Communication): Specialized Roles
    // =========================================================================

    // --- Embedded Systems ---
    CareerRoleModel(
        id: 'ece_emb_linux',
        title: 'Embedded Linux Engineer',
        category: 'ECE',
        iconCode: 0xe30a,
        requiredSkills: ['Yocto', 'Kernel Drivers', 'C/C++', 'U-Boot', 'Bash'],
        description: 'Develops systems running Linux on embedded hardware.'),
    CareerRoleModel(
        id: 'ece_emb_auto',
        title: 'Automotive Embedded Engineer',
        category: 'ECE',
        iconCode: 0xe531,
        requiredSkills: ['AUTOSAR', 'CAN', 'MISRA C', 'Simulink', 'ISO 26262'],
        description: 'Develops critical software for vehicle ECUs.'),
    CareerRoleModel(
        id: 'ece_emb_firmware',
        title: 'Bare Metal Firmware Engineer',
        category: 'ECE',
        iconCode: 0xe868,
        requiredSkills: [
          'C',
          'Assembly',
          'ARM Cortex',
          'Registers',
          'Low Power'
        ],
        description: 'Writes efficient code directly for microcontrollers.'),
    CareerRoleModel(
        id: 'ece_emb_iot',
        title: 'IoT Embedded Engineer',
        category: 'ECE',
        iconCode: 0xe1b0,
        requiredSkills: ['FreeRTOS', 'MQTT', 'ESP32', 'BLE', 'WiFi Stack'],
        description:
            'Connects small devices to the internet within constraints.'),

    // --- VLSI ---
    CareerRoleModel(
        id: 'ece_vlsi_rtl',
        title: 'RTL Design Engineer',
        category: 'ECE',
        iconCode: 0xe322,
        requiredSkills: [
          'Verilog',
          'SystemVerilog',
          'Digital Logic',
          'Synthesis',
          'Linting'
        ],
        description:
            'Designs digital circuits using Hardware Description Languages.'),
    CareerRoleModel(
        id: 'ece_vlsi_verif',
        title: 'VLSI Verification Engineer',
        category: 'ECE',
        iconCode: 0xe86c,
        requiredSkills: [
          'SystemVerilog',
          'UVM',
          'Testbenches',
          'Coverage',
          'Edaplayground'
        ],
        description: 'Verifies chip designs thoroughly before fabrication.'),
    CareerRoleModel(
        id: 'ece_vlsi_phys',
        title: 'Physical Design Engineer',
        category: 'ECE',
        iconCode: 0xe30b,
        requiredSkills: [
          'Place & Route',
          'Static Timing Analysis',
          'DRC/LVS',
          'Tcl'
        ],
        description:
            'Translates logic designs into physical layout geometries.'),
    CareerRoleModel(
        id: 'ece_vlsi_fpga',
        title: 'FPGA Engineer',
        category: 'ECE',
        iconCode: 0xe322,
        requiredSkills: [
          'Vivado',
          'Quartus',
          'VHDL/Verilog',
          'DSP',
          'High Speed I/O'
        ],
        description:
            'Programs Field Programmable Gate Arrays for custom hardware.'),

    // --- Telecom & RF ---
    CareerRoleModel(
        id: 'ece_tel_rf',
        title: 'RF Design Engineer',
        category: 'ECE',
        iconCode: 0xe1b8,
        requiredSkills: [
          'ADS',
          'Smith Chart',
          'Antenna Design',
          'RF PCB',
          'Testing'
        ],
        description: 'Designs Radio Frequency circuits and antennas.'),
    CareerRoleModel(
        id: 'ece_tel_5g',
        title: '5G Protocol Engineer',
        category: 'ECE',
        iconCode: 0xe0b0,
        requiredSkills: [
          '3GPP',
          'LTE/5G NR',
          'Protocol Stack',
          'Wireshark',
          'C++'
        ],
        description: 'Develops and tests cellular communication protocols.'),
    CareerRoleModel(
        id: 'ece_tel_optical',
        title: 'Optical Network Engineer',
        category: 'ECE',
        iconCode: 0xe412,
        requiredSkills: ['Fiber Optics', 'DWDM', 'OTDR', 'Network Planning'],
        description: 'Designs and maintains high-speed optical networks.'),

    // --- ECE Board Design ---
    CareerRoleModel(
        id: 'ece_board_layout',
        title: 'PCB Layout Engineer',
        category: 'ECE',
        iconCode: 0xe30b,
        requiredSkills: [
          'Altium Designer',
          'SI/PI',
          'High Speed Routing',
          'Routing'
        ],
        description: 'Creates physical board layouts from schematics.'),

    // =========================================================================
    // EEE (Electrical): Specialized Roles
    // =========================================================================

    // --- Power Systems ---
    CareerRoleModel(
        id: 'eee_power_trans',
        title: 'Transmission Engineer',
        category: 'EEE',
        iconCode: 0xe1e0,
        requiredSkills: [
          'PLS-CADD',
          'High Voltage',
          'Tower Design',
          'Line Routing'
        ],
        description: 'Designs high voltage transmission lines and towers.'),
    CareerRoleModel(
        id: 'eee_power_dist',
        title: 'Distribution Engineer',
        category: 'EEE',
        iconCode: 0xe1e0,
        requiredSkills: [
          'Power Flow',
          'Cyme/Etap',
          'Load Planning',
          'Grid Reliability'
        ],
        description: 'Manages the distribution of power to end users.'),
    CareerRoleModel(
        id: 'eee_power_ev',
        title: 'EV Powertrain Engineer',
        category: 'EEE',
        iconCode: 0xe531,
        requiredSkills: [
          'Motor Design',
          'Inverters',
          'Battery Pack',
          'Thermal Mgmt'
        ],
        description: 'Designs electrical systems for Electric Vehicles.'),

    // --- Control & Automation ---
    CareerRoleModel(
        id: 'eee_ctrl_plc',
        title: 'PLC Programmer',
        category: 'EEE',
        iconCode: 0xe8b8,
        requiredSkills: [
          'Ladder Logic',
          'Siemens/Allen-Bradley',
          'HMI',
          'Automation'
        ],
        description: 'Programs industrial controllers for factory automation.'),
    CareerRoleModel(
        id: 'eee_ctrl_scada',
        title: 'SCADA Engineer',
        category: 'EEE',
        iconCode: 0xe8b8,
        requiredSkills: [
          'Wonderware',
          'Ignition',
          'communication protocols',
          'Historian'
        ],
        description:
            'Builds supervisory control and data acquisition systems.'),
    CareerRoleModel(
        id: 'eee_ctrl_robot',
        title: 'Robotics Control Engineer',
        category: 'EEE',
        iconCode: 0xe99a,
        requiredSkills: ['ROS', 'Kinematics', 'Servo Drives', 'Motion Control'],
        description:
            'Designs control algorithms for robotic arms and systems.'),

    // --- Electrical Design ---
    CareerRoleModel(
        id: 'eee_des_panel',
        title: 'Panel Design Engineer',
        category: 'EEE',
        iconCode: 0xe30b,
        requiredSkills: [
          'EPLAN',
          'AutoCAD Electrical',
          'Switchgear',
          'IEC Standards'
        ],
        description: 'Designs electrical control panels and switchboards.'),
    CareerRoleModel(
        id: 'eee_des_bldg',
        title: 'Building Electrical Engineer',
        category: 'EEE',
        iconCode: 0xe0e6,
        requiredSkills: [
          'Revit MEP',
          'Lighting Design',
          'Fire Alarm',
          'Load Schedule'
        ],
        description: 'Designs electrical systems for commercial buildings.'),

    // --- Renewable ---
    CareerRoleModel(
        id: 'eee_renew_solar',
        title: 'Solar PV Design Engineer',
        category: 'EEE',
        iconCode: 0xe90f,
        requiredSkills: [
          'PVsyst',
          'Helioscope',
          'Shadow Analysis',
          'DC Design'
        ],
        description: 'Designs Solar Photovoltaic plants and rooftop systems.'),
    CareerRoleModel(
        id: 'eee_renew_wind',
        title: 'Wind Energy Engineer',
        category: 'EEE',
        iconCode: 0xe90f,
        requiredSkills: [
          'Turbine Control',
          'Grid Compliance',
          'Wind Resource',
          'SCADA'
        ],
        description: 'Works on wind turbine systems and farms.'),

    // =========================================================================
    // Mechanical: Specialized Roles
    // =========================================================================

    // --- Design (CAD) ---
    CareerRoleModel(
        id: 'mech_cad_sw',
        title: 'Design Engineer (SolidWorks)',
        category: 'Mechanical',
        iconCode: 0xe869,
        requiredSkills: [
          'SolidWorks',
          '3D Modeling',
          'Drafting',
          'Sheet Metal'
        ],
        description: 'Designs products and parts using SolidWorks.'),
    CareerRoleModel(
        id: 'mech_cad_catia',
        title: 'Design Engineer (CATIA)',
        category: 'Mechanical',
        iconCode: 0xe539,
        requiredSkills: [
          'CATIA V5/3DExp',
          'Surfacing',
          'Aerospace Design',
          'Assembly'
        ],
        description:
            'Designs complex surfaces mainly for Automotive/Aerospace.'),
    CareerRoleModel(
        id: 'mech_cad_nx',
        title: 'Design Engineer (NX)',
        category: 'Mechanical',
        iconCode: 0xe869,
        requiredSkills: ['Siemens NX', 'Modeling', 'Teamcenter', 'PLM'],
        description: 'Designs utilizing Siemens NX suite.'),
    CareerRoleModel(
        id: 'mech_cad_creo',
        title: 'Design Engineer (Creo)',
        category: 'Mechanical',
        iconCode: 0xe869,
        requiredSkills: [
          'PTC Creo',
          'Parametric Modeling',
          'Mechanism',
          'GD&T'
        ],
        description: 'Designs heavy machinery and engines.'),

    // --- Analysis (CAE) ---
    CareerRoleModel(
        id: 'mech_cae_fea',
        title: 'Structural Analyst (FEA)',
        category: 'Mechanical',
        iconCode: 0xe30b,
        requiredSkills: [
          'Ansys Mechanical',
          'Abaqus',
          'Stress Analysis',
          'Vibration'
        ],
        description:
            'Evaluates structural integrity using Finite Element Analysis.'),
    CareerRoleModel(
        id: 'mech_cae_cfd',
        title: 'CFD Engineer',
        category: 'Mechanical',
        iconCode: 0xe1ff,
        requiredSkills: [
          'Ansys Fluent',
          'Star-CCM+',
          'Fluid Dynamics',
          'Thermal'
        ],
        description: 'Simulates fluid flow and thermal behavior.'),
    CareerRoleModel(
        id: 'mech_cae_crash',
        title: 'Crash Safety Engineer',
        category: 'Mechanical',
        iconCode: 0xe531,
        requiredSkills: [
          'LS-DYNA',
          'Pam-Crash',
          'Impact Mechanics',
          'Regulations'
        ],
        description: 'Simulates vehicle crash scenarios for safety.'),

    // --- Domain Specific ---
    CareerRoleModel(
        id: 'mech_dom_hvac',
        title: 'HVAC Design Engineer',
        category: 'Mechanical',
        iconCode: 0xeac9,
        requiredSkills: ['HAP', 'Revit MEP', 'Duct Sizing', 'Chillers'],
        description: 'Designs heating and cooling systems for buildings.'),
    CareerRoleModel(
        id: 'mech_dom_pipe',
        title: 'Piping Design Engineer',
        category: 'Mechanical',
        iconCode: 0xe000,
        requiredSkills: ['PDMS', 'SP3D', 'ASME B31.3', 'Isometrics'],
        description: 'Designs complex piping layouts for process plants.'),
    CareerRoleModel(
        id: 'mech_dom_mold',
        title: 'Mold Design Engineer',
        category: 'Mechanical',
        iconCode: 0xe30b,
        requiredSkills: [
          'Injection Molding',
          'Tool Design',
          'Moldflow',
          'Material Science'
        ],
        description: 'External mold and tooling design for manufacturing.'),
    CareerRoleModel(
        id: 'mech_dom_auto_biw',
        title: 'BIW Design Engineer',
        category: 'Mechanical',
        iconCode: 0xe531,
        requiredSkills: [
          'Body in White',
          'Spot Welding',
          'Sheet Metal',
          'CATIA'
        ],
        description: 'Designs the car body structure.'),

    // =========================================================================
    // Civil: Specialized Roles
    // =========================================================================

    // --- Structural ---
    CareerRoleModel(
        id: 'civil_str_steel',
        title: 'Structural Engineer (Steel)',
        category: 'Civil',
        iconCode: 0xe7f1,
        requiredSkills: [
          'Tekla Structures',
          'Steel Connections',
          'AISC Codes',
          'STAAD'
        ],
        description:
            'Designs steel frameworks for industrial and commercial buildings.'),
    CareerRoleModel(
        id: 'civil_str_conc',
        title: 'Structural Engineer (Concrete)',
        category: 'Civil',
        iconCode: 0xe7f1,
        requiredSkills: ['ETABS', 'SAFE', 'RCDC', 'Reinforcement Detailing'],
        description: 'Designs reinforced concrete buildings and foundations.'),
    CareerRoleModel(
        id: 'civil_str_bridge',
        title: 'Bridge Engineer',
        category: 'Civil',
        iconCode: 0xe558,
        requiredSkills: ['Midas Civil', 'Bridge Deck', 'Pier Design', 'AASHTO'],
        description: 'Specializes in the design and analysis of bridges.'),

    // --- Transportation ---
    CareerRoleModel(
        id: 'civil_trans_hway',
        title: 'Highway Engineer',
        category: 'Civil',
        iconCode: 0xe530,
        requiredSkills: [
          'AutoCAD Civil 3D',
          'MX Road',
          'Pavement Design',
          'Alignment'
        ],
        description: 'Designs roads, highways, and interchanges.'),
    CareerRoleModel(
        id: 'civil_trans_rail',
        title: 'Railway Design Engineer',
        category: 'Civil',
        iconCode: 0xe570,
        requiredSkills: [
          'Track Layout',
          'Alignment',
          'MicroStation',
          'Rail Standards'
        ],
        description: 'Designs railway tracks and related infrastructure.'),

    // --- Geotech & Water ---
    CareerRoleModel(
        id: 'civil_geo',
        title: 'Geotechnical Engineer',
        category: 'Civil',
        iconCode: 0xe55b,
        requiredSkills: [
          'Soil Analysis',
          'Slope Stability',
          'PLAXIS',
          'Foundations'
        ],
        description: 'Analyzes soil behavior to support structures.'),
    CareerRoleModel(
        id: 'civil_water',
        title: 'Hydraulic Modeler',
        category: 'Civil',
        iconCode: 0xe798,
        requiredSkills: [
          'HEC-RAS',
          'WaterGEMS',
          'Flood Analysis',
          'Sewer Design'
        ],
        description: 'Models water flow, floods, and distribution networks.'),

    // --- Construction Mgmt ---
    CareerRoleModel(
        id: 'civil_con_plan',
        title: 'Planning Engineer',
        category: 'Civil',
        iconCode: 0xf603,
        requiredSkills: [
          'Primavera P6',
          'MS Project',
          'Critical Path',
          'Resource Mgmt'
        ],
        description: 'Creates and manages construction schedules.'),
    CareerRoleModel(
        id: 'civil_con_bim',
        title: 'BIM Coordinator',
        category: 'Civil',
        iconCode: 0xe30b,
        requiredSkills: [
          'Navisworks',
          'Revit',
          'Clash Detection',
          '4D Simulation'
        ],
        description: 'Coordinates 3D models from different disciplines.'),

    // =========================================================================
    // Chemical: Specialized Roles
    // =========================================================================

    // --- Process ---
    CareerRoleModel(
        id: 'chem_proc_sim',
        title: 'Process Simulation Engineer',
        category: 'Chemical',
        iconCode: 0xe8e3,
        requiredSkills: [
          'Aspen Plus',
          'HYSYS',
          'Heat Mass Balance',
          'Thermodynamics'
        ],
        description: 'Simulates steady-state chemical processes.'),
    CareerRoleModel(
        id: 'chem_proc_equip',
        title: 'Static Equipment Engineer',
        category: 'Chemical',
        iconCode: 0xe869,
        requiredSkills: [
          'PV Elite',
          'Vessel Design',
          'Heat Exchangers',
          'API Codes'
        ],
        description: 'Designs pressure vessels and storage tanks.'),

    // --- Industry Specific ---
    CareerRoleModel(
        id: 'chem_ind_oil',
        title: 'Refinery Process Engineer',
        category: 'Chemical',
        iconCode: 0xe530,
        requiredSkills: [
          'Distillation',
          'Cracking',
          'Desulfurization',
          'Safety'
        ],
        description: 'Optimizes processes within oil refineries.'),
    CareerRoleModel(
        id: 'chem_ind_pharma',
        title: 'Pharma Process Engineer',
        category: 'Chemical',
        iconCode: 0xe58b,
        requiredSkills: [
          'GMP',
          'Validation',
          'Batch Processing',
          'Sterilization'
        ],
        description: 'Designs processes for pharmaceutical manufacturing.'),
    CareerRoleModel(
        id: 'chem_ind_water',
        title: 'Water Treatment Engineer',
        category: 'Chemical',
        iconCode: 0xe798,
        requiredSkills: [
          'Reverse Osmosis',
          'Membranes',
          'Water Chemistry',
          'Desalination'
        ],
        description: 'Designs systems to purify water for industrial use.'),

    // --- Safety ---
    CareerRoleModel(
        id: 'chem_safe_hazop',
        title: 'Process Safety Engineer',
        category: 'Chemical',
        iconCode: 0xe58b,
        requiredSkills: [
          'HAZOP Facilitation',
          'LOPA',
          'Risk Analysis',
          'Relief Sizing'
        ],
        description: 'Ensures chemical processes are safe and compliant.'),

    // =========================================================================
    // AI & Data Science: Specialized Roles
    // =========================================================================

    // --- Artificial Intelligence ---
    CareerRoleModel(
        id: 'ai_engineer',
        title: 'AI Engineer',
        category: 'CSE/IT',
        // Generic "Smart" icon or Computer icon
        iconCode: 0xe30a,
        requiredSkills: [
          'Python',
          'TensorFlow',
          'PyTorch',
          'Deep Learning',
          'Neural Networks',
          'NLP',
          'Computer Vision',
          'Mathematics',
          'Probability & Statistics',
          'Docker',
          'Cloud Computing'
        ],
        description:
            'Builds intelligent systems capable of performing tasks that typically require human intelligence.'),
    CareerRoleModel(
        id: 'ml_engineer',
        title: 'Machine Learning Engineer',
        category: 'CSE/IT',
        iconCode: 0xe30a,
        requiredSkills: [
          'Python',
          'Scikit-learn',
          'Supervised Learning',
          'Unsupervised Learning',
          'Feature Engineering',
          'Model Evaluation',
          'MLOps',
          'Data Modeling',
          'Ensemble Methods',
          'SQL'
        ],
        description:
            'Designs and deploys scalable machine learning models and pipelines.'),
    CareerRoleModel(
        id: 'data_scientist',
        title: 'Data Scientist',
        category: 'CSE/IT',
        iconCode: 0xe06c, // Analytics
        requiredSkills: [
          'Python',
          'R',
          'Pandas',
          'NumPy',
          'Matplotlib/Seaborn',
          'Statistics',
          'Hypothesis Testing',
          'SQL',
          'Data Visualization',
          'Machine Learning Algorithms',
          'Big Data Basics'
        ],
        description:
            'Analyzes complex data to derive actionable insights and solve business problems.'),
    CareerRoleModel(
        id: 'nlp_specialist',
        title: 'NLP Specialist',
        category: 'CSE/IT',
        iconCode: 0xe0bf, // Chat/Voice
        requiredSkills: [
          'Natural Language Processing',
          'Linguistics',
          'Tokenization',
          'Word Embeddings',
          'BERT',
          'Transformers',
          'Spacy',
          'NLTK',
          'Generative AI (LLMs)',
          'Prompt Engineering'
        ],
        description:
            'Focuses on the interaction between computers and human language.'),
    CareerRoleModel(
        id: 'cv_engineer',
        title: 'Computer Vision Engineer',
        category: 'CSE/IT',
        iconCode: 0xe412, // Camera
        requiredSkills: [
          'OpenCV',
          'Image Processing',
          'Convolutional Neural Networks (CNNs)',
          'Object Detection (YOLO/R-CNN)',
          'Image Segmentation',
          'Video Analysis',
          'PyTorch/TensorFlow',
          '3D Vision',
          'Deep Learning'
        ],
        description:
            'Enables computers to interpret and process visual information from the world.'),
    CareerRoleModel(
        id: 'data_analyst',
        title: 'Data Analyst',
        category: 'CSE/IT',
        iconCode: 0xe24b, // Chart
        requiredSkills: [
          'SQL',
          'Excel (Advanced)',
          'Tableau',
          'PowerBI',
          'Python Basics',
          'Data Cleaning',
          'Exploratory Data Analysis',
          'Reporting & Dashboards',
          'Statistics Fundamentals'
        ],
        description:
            'Interprets data and turns it into information offering ways to improve business operations.'),
  ];
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // Helper function to launch URLs
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  // Section card widget
  Widget sectionCard(String title, Widget content) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 1500, // fixed width for all cards
          maxWidth: 1500,
        ),
        child: Card(
          color: const Color.fromARGB(255, 255, 255, 255),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                content,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget for a team member with LinkedIn button
  Widget teamMember(String name, String subtitle, String linkedInUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,   // <-- Center icon with text block
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 66, 64, 64)),
              ),
            ],
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: Image.network(
              'https://cdn-icons-png.flaticon.com/512/174/174857.png',
              width: 24,
              height: 24,
            ),
            onPressed: () {
              _launchURL(linkedInUrl);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 13, 125, 223),
        toolbarHeight: 80,
        title: const Text(
          ' About NaVIA – Smart Navigation Visual Impaired Assistance',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 34,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            sectionCard(
              'RBB4013 / EDB4703 – System Integrated Design Project',
              const Text('Universiti Teknologi PETRONAS (UTP)\n'
              'Bachelor of Computer Engineering - September 2025',
                  style: TextStyle(fontSize: 16)),
            ),
            sectionCard(
              'What is NaVIA?',
              const Text(
                'Smart Navigation Visual Impaired Assistance (NaVIA) is an intelligent mobility aid designed to support visually impaired individuals by providing real-time navigation guidance, obstacle detection,\n'
                'and safety alerts. The system integrates hardware, software, and IoT-based technologies to enhance user independence in both indoor and outdoor environments.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            sectionCard(
              'Project Supervisor',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  teamMember(
                    'Dr. Norashikin Bt Yahya',
                    'Senior Lecturer (Electrical & Electronics Engineering)',
                    'https://www.linkedin.com/in/norashikin-yahya-0a78a531/',
                  ),
                ],
              ),
            ),
            sectionCard(
              'Project Team',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  teamMember(
                    'Ainul Raudhah Binti Nor Hakma',
                    '21001745',
                    'https://www.linkedin.com/in/ainul-raudhah-nor-hakma-81857a2a2',
                  ),
                  teamMember(
                    'Arif Syahmi Bin Muhamad \'Asri',
                    '21001327',
                    'https://www.linkedin.com/in/arif-syahmi-97917932a',
                  ),
                  teamMember(
                    'Foo Zhe Cheng',
                    '21000613',
                    'https://www.linkedin.com/in/foo-zhe-cheng-6284b0211',
                  ),
                  teamMember(
                    'Muhammad Fakhrul Hafiz Bin Mohd Anuar',
                    '21001623',
                    'https://www.linkedin.com/in/fakhrullhafiz',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 0),
            const Center(
              child: Text(
                'For more information, can contact us at LinkedIn!',
                style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold,),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
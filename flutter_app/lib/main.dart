import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await Supabase.initialize(
    url: "https://mskvhwpicxwxjrmmhjst.supabase.co",
    anonKey:
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1za3Zod3BpY3h3eGpybW1oanN0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMzODQzMDAsImV4cCI6MjA3ODk2MDMwMH0.X9x59QmyLQbhoKT879dpWQSlOfpskyD24RYXq_3ml1U",
  );

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Bird Feeder",
      theme: ThemeData(primarySwatch: Colors.green),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;
  bool showPassword = false;

  Future<void> login() async {
    try {
      setState(() => loading = true);

      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      if (res.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DashboardPage()),
        );
      }
    } on AuthException catch (e) {
      String message = "Erreur de connexion";

      if (e.message.contains("Invalid login credentials")) {
        message = "❌ Email ou mot de passe incorrect";
      } else if (e.message.contains("Email not confirmed")) {
        message = "⚠️ Veuillez vérifier votre email avant de vous connecter";
      } else {
        message = "❌ ${e.message}";
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("📶 Pas de connexion internet")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur inconnue : $e")));
    } finally {
      setState(() => loading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: Center(
        child: Card(
          elevation: 6,
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.eco, size: 60, color: Colors.green),
                const SizedBox(height: 10),
                const Text("Bird Feeder Login",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: passCtrl,
                  obscureText: !showPassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(showPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => showPassword = !showPassword),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: loading ? null : login,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Login", style: TextStyle(fontSize: 18)),
                ),

                TextButton(
                  onPressed: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => SignupPage())),
                  child: const Text("Créer un compte"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;
  bool showPassword = false;

  Future<void> signup() async {
    try {
      setState(() => loading = true);

      final res = await Supabase.instance.client.auth.signUp(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      if (res.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("✅ Compte créé ! Vérifiez votre email.")));

        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      String message = "Erreur d'inscription";

      if (e.message.contains("password should be at least")) {
        message = "🔐 Mot de passe trop court (min 6 caractères)";
      }
      else if (e.message.contains("User already registered")) {
        message = "⚠️ Cet email est déjà utilisé";
      }
      else {
        message = "❌ ${e.message}";
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("📶 Pas de connexion internet")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur inconnue : $e")));
    } finally {
      setState(() => loading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: Center(
        child: Card(
          elevation: 6,
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_add, size: 60, color: Colors.green),
                const SizedBox(height: 10),
                const Text("Créer un compte",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: passCtrl,
                  obscureText: !showPassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(showPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => showPassword = !showPassword),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: loading ? null : signup,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Créer", style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}
class _DashboardPageState extends State<DashboardPage> {
  final String espIp = "192.168.1.20";

  int pir = 0;
  int led = 0;
  int servo = 0;
  bool lowFood = false;

  Timer? timer;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    // Poll every 1s (ajuste si tu veux moins fréquent)
    timer = Timer.periodic(const Duration(seconds: 1), (_) => fetchStatus());
  }


  Future<void> fetchStatus() async {
    try {
      final response = await http.get(
        Uri.parse("http://$espIp/"),
        headers: {
          "Cache-Control": "no-cache",
          "Pragma": "no-cache",
          "Accept": "application/json"
        },
      ).timeout(const Duration(seconds: 2));

      print("STATUS: ${response.statusCode}");
      print("RAW JSON = ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Conversion sécurisée des valeurs
        final newPir = (data["pir"] is num) ? (data["pir"] as num).toInt() : 0;
        final newLed = (data["led"] is num) ? (data["led"] as num).toInt() : 0;
        final newServo = (data["servo"] is num) ? (data["servo"] as num).toInt() : 0;

        // Vérification correcte de low_food
        final newLowFood = data["low_food"] == true || data["low_food"] == "true";

        setState(() {
          pir = newPir;
          led = newLed;
          servo = newServo;
          lowFood = newLowFood;
        });

        await saveToSupabase();

        print("✅ Données mises à jour - PIR: $pir, LED: $led, Servo: $servo, Low Food: $lowFood");
      } else {
        print("❌ Erreur HTTP: ${response.statusCode}");
      }
    } on TimeoutException {
      print("⏱️ fetchStatus error: Timeout - ESP ne répond pas");
    } catch (e) {
      print("❌ fetchStatus error: $e");
    }
  }

  Future<void> saveToSupabase() async {
    if (saving) return; // éviter chevauchement
    saving = true;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      await Supabase.instance.client.from("bird_feeder_data").insert({
        "user_id": user.id,
        "pir": pir,
        "led": led,
        "servo": servo,
        "low_food": lowFood,

      });
    } catch (e) {
      print("Erreur Supabase insert: $e");
    } finally {
      saving = false;
    }
  }

  Future<void> logAction(String action, String? value) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      await Supabase.instance.client.from("actions_log").insert({
        "user_id": user.id,
        "action": action,
        "value": value ?? "",
        "created_at": DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print("Erreur logging action: $e");
    }
  }

  Future<void> toggleLed(bool on) async {
    try {
      await http.get(Uri.parse("http://$espIp/led=${on ? "on" : "off"}")).timeout(const Duration(seconds: 5));
      await logAction("LED", on ? "ON" : "OFF");
    } catch (e) {
      print("toggleLed error: $e");
    }
  }

  Future<void> moveServo(bool open) async {
    try {
      await http.get(Uri.parse("http://$espIp/servo=${open ? "open" : "close"}")).timeout(const Duration(seconds: 5));
      await logAction("SERVO", open ? "OPEN" : "CLOSE");
    } catch (e) {
      print("moveServo error: $e");
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Bird Feeder"),
        backgroundColor: Colors.green,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesPage()),
            ),
          ),
          //IconButton(
            //icon: const Icon(Icons.person),
           // onPressed: () => Navigator.push(context,
                //MaterialPageRoute(builder: (_) => ProfilePage())),
          //),
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => ActionsPage())),
          ),
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => GalleryPage())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Supabase.instance.client.auth.signOut();
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => LoginPage()));
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// ********** Alerte Low Food **********
            if (lowFood)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.white, size: 30),
                    SizedBox(width: 8),
                    Text(
                        "Niveau de nourriture insuffisant",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            /// ********** Card Status **********
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text("État en temps réel",
                        style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Icon(
                              pir == 1
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: pir == 1 ? Colors.orange : Colors.grey,
                              size: 40,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              pir == 1 ? "Mouvement" : "Aucun",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),

                        Column(
                          children: [
                            Icon(
                              Icons.lightbulb,
                              color: led == 1
                                  ? Colors.yellow.shade700
                                  : Colors.grey,
                              size: 40,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              led == 1 ? "LED ON" : "LED OFF",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),

                        Column(
                          children: [
                            const Icon(Icons.settings, size: 40),
                            const SizedBox(height: 6),
                            Text("Servo : $servo°",
                                style: const TextStyle(fontSize: 16))
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            /// ********** Card Controle **********
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text("Contrôle Manuel",
                        style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.all(12),
                          ),
                          icon: const Icon(Icons.light_mode),
                          label: const Text("LED ON"),
                          onPressed: () => toggleLed(true),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.all(12),
                          ),
                          icon: const Icon(Icons.power_settings_new),
                          label: const Text("LED OFF"),
                          onPressed: () => toggleLed(false),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.all(12),
                          ),
                          icon: const Icon(Icons.lock_open),
                          label: const Text("Ouvrir"),
                          onPressed: () => moveServo(true),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            padding: const EdgeInsets.all(12),
                          ),
                          icon: const Icon(Icons.lock),
                          label: const Text("Fermer"),
                          onPressed: () => moveServo(false),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}



class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: FutureBuilder(
        future: supabase.from('profiles').select().eq('id', supabase.auth.currentUser!.id).maybeSingle(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final p = snapshot.data as Map<String, dynamic>?;
          if (p == null) return const Center(child: Text("Aucun profil trouvé."));
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Email: ${p['email']}", style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text("Created at: ${p['created_at']}"),
              ],
            ),
          );
        },
      ),
    );
  }
}


class ActionsPage extends StatelessWidget {
  const ActionsPage({super.key});

  String formatDate(String iso) {
    try {
      final date = DateTime.parse(iso).toLocal();
      return DateFormat('dd/MM/yyyy • HH:mm').format(date);
    } catch (_) {
      return iso;
    }
  }

  IconData getIcon(String action) {
    if (action.contains("LED")) return Icons.lightbulb;
    if (action.contains("SERVO")) return Icons.settings;
    if (action.contains("WARNING")) return Icons.warning;
    return Icons.info;
  }

  Color getColor(String action, String value) {
    if (action.contains("LED")) {
      return value == "ON" ? Colors.green : Colors.orange;
    }
    if (action.contains("SERVO")) return Colors.blue;
    if (action.contains("WARNING")) return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique des actions"),
        backgroundColor: Colors.green,
      ),

      body: FutureBuilder(
        future: supabase
            .from('actions_log')
            .select()
            .eq('user_id', supabase.auth.currentUser!.id)
            .order('created_at', ascending: false),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final actions = snapshot.data as List<dynamic>?;

          if (actions == null || actions.isEmpty) {
            return const Center(
              child: Text(
                "Aucune action enregistrée",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: actions.length,
            itemBuilder: (context, i) {
              final a = actions[i] as Map<String, dynamic>;
              final action = a['action'] ?? "Action";
              final value = a['value'] ?? "";
              final time = a['created_at'] ?? "";
              final color = getColor(action, value);

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.2),
                    child: Icon(getIcon(action), color: color),
                  ),
                  title: Text(
                    action,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  subtitle: Text(formatDate(time)),
                  trailing: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


// ================= BIRD GALLERY PAGE =================
//import 'package:flutter/material.dart';

// 'package:supabase_flutter/supabase_flutter.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> images = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  /// 🟢 Nettoie le nom :
  /// enlève chiffres + extension + _ -
  String cleanName(String name) {
    name = name.replaceAll(RegExp(r'\.(jpg|jpeg|png|webp)$', caseSensitive: false), '');
    name = name.replaceAll(RegExp(r'[0-9]'), '');
    name = name.replaceAll(RegExp(r'[_-]+'), ' ');
    return name.trim();
  }

  /// Convert format date
  String formatTimestamp(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date.toLocal());
    } catch (e) {
      return isoString;
    }
  }

  /// Charger images
  Future<void> loadImages() async {
    try {
      final response = await supabase.storage.from('birds').list();

      List<Map<String, dynamic>> result = [];

      for (final file in response) {
        final publicUrl = supabase.storage.from('birds').getPublicUrl(file.name);

        result.add({
          'name': file.name,
          'url': publicUrl,
          'created_at': file.createdAt ?? "",
        });
      }

      setState(() {
        images = result;
        loading = false;
      });
    } catch (e) {
      print("Erreur chargement images: $e");
      setState(() => loading = false);
    }
  }
  //new
  Future<void> deleteImage(String name) async {
    try {
      await supabase.storage.from('birds').remove([name]);

      setState(() {
        images.removeWhere((img) => img['name'] == name);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image supprimée avec succès")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur suppression: $e")),
      );
    }
  }
  Future<void> addToFavorites(String name, String url) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await supabase.from("favorite_birds").insert({
        "user_id": user.id,
        "file_name": name,
        "url": url,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ajouté aux favoris ❤️")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Déjà favori ou erreur : $e")),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Galerie d'oiseaux"),
        backgroundColor: Colors.green,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : images.isEmpty
          ? const Center(child: Text("Aucune image trouvée"))
          : GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          final img = images[index];
          final createdAt = formatTimestamp(img['created_at']);

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ImagePreviewPage(
                            imageUrl: img['url'],
                            title: cleanName(img['name']),
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        img['url'],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                        const Icon(Icons.error, size: 40),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// 🟢 NOM (ligne seule)
                      Text(
                        cleanName(img['name']),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 4),

                      /// 🕒 DATE (ligne séparée)
                      Text(
                        formatTimestamp(img['created_at']),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),


                      const SizedBox(height: 6),

                      /// ⭐ BOUTON FAVORI
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          /// ⭐ FAVORI
                          IconButton(
                            icon: const Icon(Icons.star, color: Colors.orange),
                            onPressed: () {
                              addToFavorites(img['name'], img['url']);
                            },
                          ),

                          /// 🗑️ SUPPRIMER
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Confirmer"),
                                  content: const Text("Supprimer cette image ?"),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text("Annuler")),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          deleteImage(img['name']);
                                        },
                                        child: const Text("Supprimer",
                                            style: TextStyle(color: Colors.red))),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),


                    ],
                  ),
                ),

              ],
            ),
          );

        },
      ),
    );
  }
}


class ImagePreviewPage extends StatelessWidget {
  final String imageUrl;
  final String title;

  const ImagePreviewPage({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(title),
      ),
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
          heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 4,
          backgroundDecoration: const BoxDecoration(color: Colors.black),
        ),
      ),
    );
  }
}

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with SingleTickerProviderStateMixin {

  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> favs = [];
  bool loading = true;

  late AnimationController likeAnim;

  @override
  void initState() {
    super.initState();
    likeAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.8,
      upperBound: 1.2,
    );
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('favorite_birds')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    setState(() {
      favs = List<Map<String, dynamic>>.from(data);
      loading = false;
    });
  }

  Future<void> removeFavorite(String id) async {
    try {
      await supabase.from('favorite_birds').delete().eq('id', id);

      setState(() {
        favs.removeWhere((e) => e['id'] == id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Favori supprimé 🗑️")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur suppression: $e")),
      );
    }
  }

  @override
  void dispose() {
    likeAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Favoris"),
        backgroundColor: Colors.green,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : favs.isEmpty
          ? const Center(child: Text("Aucun favori trouvé ❤️"))
          : GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: .85,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: favs.length,
        itemBuilder: (context, i) {
          final f = favs[i];

          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      f['url'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                      const Icon(Icons.error),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    f['name'] ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
                  ),
                ),

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
                  children: [
                    /// ❤️ LIKE animation
                    ScaleTransition(
                      scale: CurvedAnimation(
                        parent: likeAnim,
                        curve: Curves.easeInOut,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.favorite,
                            color: Colors.red),
                        onPressed: () {
                          likeAnim.forward().then(
                                  (_) => likeAnim.reverse());
                        },
                      ),
                    ),

                    /// 🗑️ DELETE FAVORI
                    IconButton(
                      icon: const Icon(Icons.delete,
                          color: Colors.grey),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Confirmer"),
                            content: const Text(
                                "Supprimer ce favori ?"),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx),
                                  child: const Text("Annuler")),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  removeFavorite(f['id']);
                                },
                                child: const Text(
                                  "Supprimer",
                                  style: TextStyle(
                                      color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

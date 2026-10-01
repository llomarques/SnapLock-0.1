import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _searchController = TextEditingController();
  List<UserModel> _searchResults = [];
  List<UserModel> _friends = [];
  List<Map<String, dynamic>> _pendingRequests = [];

  bool _isSearching = false;
  bool _isLoadingLists = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingLists = true);
    try {
      final friends = await ApiService.getFriends();
      final pending = await ApiService.getPendingRequests();
      setState(() {
        _friends = friends;
        _pendingRequests = pending;
        _isLoadingLists = false;
      });
    } catch (_) {
      setState(() => _isLoadingLists = false);
    }
  }

  Future<void> _handleSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    try {
      final users = await ApiService.searchUsers(query);
      setState(() {
        _searchResults = users;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _sendRequest(String friendId) async {
    try {
      await ApiService.sendFriendRequest(friendId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitação de amizade enviada!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _acceptRequest(String requestId) async {
    try {
      await ApiService.acceptFriendRequest(requestId);
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _declineRequest(String requestId) async {
    try {
      await ApiService.declineFriendRequest(requestId);
      _loadData();
    } catch (_) {}
  }

  Future<void> _removeFriend(String friendId) async {
    try {
      await ApiService.removeFriend(friendId);
      _loadData();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: Text('Amigos & Pesquisa (RN17)', style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.bold, fontSize: 22)),
          bottom: TabBar(
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
            labelColor: AppTheme.darkBrown,
            indicatorColor: AppTheme.darkBrown,
            tabs: const [
              Tab(text: 'Pesquisa'),
              Tab(text: 'Meus Amigos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ABA 1: Pesquisa de Usuários Ativos (RN17)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _searchController,
                          label: 'Pesquisar perfis',
                          hint: 'Digite um nome ou e-mail...',
                          prefixIcon: Icons.search,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: IconButton.filled(
                          style: IconButton.styleFrom(backgroundColor: AppTheme.darkBrown),
                          onPressed: _handleSearch,
                          icon: const Icon(Icons.search, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isSearching)
                    const CircularProgressIndicator(color: AppTheme.darkBrown)
                  else
                    Expanded(
                      child: _searchResults.isEmpty
                          ? Center(
                              child: Text(
                                'Pesquise por nome ou e-mail de usuários na plataforma.',
                                style: GoogleFonts.poppins(color: AppTheme.textSecondary, fontSize: 13),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final user = _searchResults[index];
                                return Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: AppTheme.darkBrown,
                                      child: Text(user.name[0].toUpperCase(), style: GoogleFonts.cormorantGaramond(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                    title: Text(user.name, style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                                    subtitle: Text(user.email, style: GoogleFonts.poppins(color: AppTheme.textSecondary, fontSize: 12)),
                                    trailing: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkBrown),
                                      icon: const Icon(Icons.person_add, size: 16, color: Colors.white),
                                      label: Text('Adicionar', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
                                      onPressed: () => _sendRequest(user.id),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                ],
              ),
            ),

            // ABA 2: Amigos Conectados e Solicitações Pendentes
            _isLoadingLists
                ? const Center(child: CircularProgressIndicator(color: AppTheme.darkBrown))
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (_pendingRequests.isNotEmpty) ...[
                          Text(
                            'Solicitações Pendentes',
                            style: GoogleFonts.cormorantGaramond(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.mediumBrown),
                          ),
                          const SizedBox(height: 8),
                          ..._pendingRequests.map((req) {
                            final sender = req['sender'] as Map<String, dynamic>;
                            final reqId = req['requestId'] as String;
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.mediumBrown,
                                  child: Text((sender['name'] as String)[0].toUpperCase(), style: GoogleFonts.cormorantGaramond(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                                title: Text(sender['name'] as String, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                subtitle: Text(sender['email'] as String, style: GoogleFonts.poppins(fontSize: 12)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check_circle, color: AppTheme.success),
                                      onPressed: () => _acceptRequest(reqId),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.cancel, color: AppTheme.danger),
                                      onPressed: () => _declineRequest(reqId),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const Divider(height: 32),
                        ],

                        Text(
                          'Amigos Conectados (Feed Privado RN13)',
                          style: GoogleFonts.cormorantGaramond(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        if (_friends.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                'Você ainda não possui amigos na sua lista.',
                                style: GoogleFonts.poppins(color: AppTheme.textSecondary),
                              ),
                            ),
                          )
                        else
                          ..._friends.map((friend) => Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppTheme.darkBrown,
                                    child: Text(friend.name[0].toUpperCase(), style: GoogleFonts.cormorantGaramond(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                  title: Text(friend.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                  subtitle: Text(friend.email, style: GoogleFonts.poppins(fontSize: 12)),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.person_remove_outlined, color: AppTheme.danger),
                                    onPressed: () => _removeFriend(friend.id),
                                  ),
                                ),
                              )),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

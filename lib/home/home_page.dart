import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_get_users_bloc/models/user.dart';

import 'bloc/home_bloc.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> _dropdownOptions = <String>[
    'All users',
    'Even users',
    'Odd users'
  ];
  String _dropdownValue = 'All users';

  HomeBloc _homeBloc;

  @override
  void dispose() {
    _homeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Users list"),
        actions: [
          DropdownButton<String>(
            value: _dropdownValue,
            icon: Icon(Icons.arrow_downward, color: Colors.white),
            iconSize: 18,
            style: TextStyle(color: Colors.white),
            dropdownColor: Theme.of(context).primaryColor,
            underline: Container(
              height: 2,
              color: Colors.blue[100],
            ),
            onChanged: (String newValue) {
              setState(() {
                _dropdownValue = newValue;
                if (_dropdownValue == _dropdownOptions[0]) {
                  _homeBloc.add(GetAllUsersEvent());
                } else if (_dropdownValue == _dropdownOptions[1]) {
                  _homeBloc.add(FilterUsersEvent(filterEven: false));
                } else {
                  _homeBloc.add(FilterUsersEvent(filterEven: true));
                }
              });
            },
            items:
                _dropdownOptions.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) {
          _homeBloc = HomeBloc();
          _homeBloc.add(GetAllUsersEvent());
          return _homeBloc;
        },
        child: BlocConsumer<HomeBloc, HomeState>(
          listener: (context, state) {
            // para mostrar dialogos o snackbars
            if (state is ErrorState) {
              Scaffold.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text("Error: ${state.error}")),
                );
            }
          },
          builder: (context, state) {
            if (state is ShowUsersState) {
              return RefreshIndicator(
                child: ListView.separated(
                  itemCount: state.usersList.length,
                  itemBuilder: (BuildContext context, int index) {
                    User user = state.usersList[index];
                    return ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${user.name}'),
                          Text('${user.phone}'),
                        ],
                      ),
                      subtitle: Text(
                          'Company: ${user.company.name}\nStreet: ${user.address.street}'),
                    );
                  },
                  separatorBuilder: (context, index) => Divider(),
                ),
                onRefresh: () async {
                  _dropdownValue = _dropdownOptions[0];
                  setState(() {});
                  BlocProvider.of<HomeBloc>(context).add(GetAllUsersEvent());
                },
              );
            } else if (state is LoadingState) {
              return Center(child: CircularProgressIndicator());
            }
            return Center(
              child: MaterialButton(
                onPressed: () {
                  BlocProvider.of<HomeBloc>(context).add(GetAllUsersEvent());
                },
                child: Text("Cargar de nuevo"),
              ),
            );
          },
        ),
      ),
    );
  }
}

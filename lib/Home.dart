import 'package:flutter/material.dart';
import 'package:lista_tarefas/Task.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  String _urlApi = "http://192.168.0.157:8080/tasks";
  //String _urlApi2 = "https://viacep.com.br/ws/01311300/json/";


  List<dynamic> _listaTarefas = [];
  Map<String, dynamic> _ultimaTarefaRemovida = Map();
  TextEditingController _controllerTarefa = TextEditingController();

  Future<File> _getFile() async {

    final diretorio = await getApplicationDocumentsDirectory();
    return File( "${diretorio.path}/dados.json" );
  }


  Future<List<Task>> _getAllTasks() async {
    http.Response response;
    response = await http.get(_urlApi);
  }


  _getTasks() async {

    http.Response response;
    response = await http.get(_urlApi);

    var retorno = json.decode( response.body );
    /*
    tarefa["titulo"] = retorno["name"];
    tarefa["realizada"] = false;

    setState(() {
      _listaTarefas.add( tarefa );
    });
     */
    for( var post in retorno ){
      print("Resposta: " + post["id"] );

    }

  }


  _salvarTarefa() {

    String textoDigitado = _controllerTarefa.text;
    Map<String, dynamic> tarefa = Map();

    tarefa["titulo"] = textoDigitado;
    tarefa["realizada"] = false;

    setState(() {
      _listaTarefas.add( tarefa );
    });

    _salvarArquivo();
    _controllerTarefa.text = "";
  }


  _salvarArquivo() async {

    var arquivo = await _getFile();
    String dados = json.encode( _listaTarefas );

    arquivo.writeAsString( dados );

    //print("Caminho: " + diretorio.path);
  }

  _lerArquivo() async {

    try{

      final arquivo = await _getFile();
      return arquivo.readAsString();

    }catch(e){
      return null;
    }
  }

  Widget criarItemLista(context, index){

    //final item = _listaTarefas[index]["titulo"];


    return Dismissible(
        key: Key( DateTime.now().millisecondsSinceEpoch.toString() ),
        direction: DismissDirection.endToStart,
        onDismissed: ( direction ) {

          //recuperando o último item excluido
          _ultimaTarefaRemovida = _listaTarefas[index];

          //removendo item da lista
          _listaTarefas.removeAt( index );
          _salvarArquivo();

          //snackbar
          final snackbar = SnackBar(
              backgroundColor: Colors.black,
              duration: Duration(seconds: 2),
              content: Text("Tarefa Removida!"),
              action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {

                  //Insere novamente item removido na lista
                  setState(() {
                    _listaTarefas.insert(index, _ultimaTarefaRemovida);
                  });
                  _salvarArquivo();
                },
              ),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackbar);

        },
        background: Container(
          color: Colors.red,
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Icon(
                Icons.delete,
                color: Colors.white,
              )
            ],
          ),
        ),
        child: CheckboxListTile(
          title: Text(_listaTarefas[index]["titulo"]),
          value:  _listaTarefas[index]["realizada"],
          onChanged: ( valorAlterado ) {

            setState(() {
              _listaTarefas[index]["realizada"] = valorAlterado;
            });
            _salvarArquivo();
          },
        )
    );
  }

  @override
  void initState() {
    super.initState();
    _salvarArquivo();
    _lerArquivo().then( ( dados ) {
      setState(() {
        _listaTarefas = json.decode( dados );
      });
    } );
  }

  @override
  Widget build(BuildContext context) {

    //print( "itens: " + _listaTarefas.toString() );
    _getTasks();
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de tarefas"),
        backgroundColor: Colors.purple,
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
        onPressed: () {
          
          showDialog(
              context: context,
            builder: (context) {

                return AlertDialog(

                  title: Text("Adicionar Tarefa"),
                  content: TextField(
                    controller: _controllerTarefa,
                    decoration: InputDecoration(
                      labelText: "Digite sua tarefa"
                    ),
                    onChanged: (text) {

                    },
                  ),
                  actions: <Widget>[
                    FlatButton(
                        child: Text("Cancelar"),
                        onPressed: () => Navigator.pop(context),
                    ),

                    FlatButton(
                      child: Text("Salvar"),
                      onPressed: () {

                        //Salvar
                        _salvarTarefa();
                        Navigator.pop(context);
                      },
                    )
                  ],
                );
            }
          );
        },
      ),
      body: Column(

        children: <Widget>[

          Expanded(

              child: ListView.builder(

                  itemCount: _listaTarefas.length,
                  itemBuilder: criarItemLista

              )),

        ],
      ),
    );
  }
}

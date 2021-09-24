import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ThemeData theme = ThemeData().copyWith(
    colorScheme: ThemeData().colorScheme.copyWith(
          primary: Color(0xff000000),
          secondary: Color(0xff808080),
          background: Color(0xffffffff),
        ),
    textTheme: ThemeData().textTheme.copyWith(
          headline1: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 16,
            letterSpacing: 0.0,
            color: Color(0xff000000),
          ),
          headline2: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 18,
            color: Color(0xff808080),
          ),
          headline3: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 20,
            color: Color(0xff000000),
          ),
        ),
  );
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Filter',
      theme: theme,
      home: FilterPage(),
    );
  }
}

class FilterPage extends StatefulWidget {
  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  List<Cinema> initialCinemaList = Cinema.initialCinemaList;
  List<Cinema> cinemaList = [];
  Category filterCategory = Category.all;
  TextEditingController controller = TextEditingController();
  late RangeValues priceValues;
  late RangeValues dateValues;
  late Gap priceGap;
  late Gap dateGap;
  bool searchOpen = false;

  @override
  initState() {
    super.initState();
    priceGap = _getGap('price');
    dateGap = _getGap('date');
    priceValues = RangeValues(priceGap.min.toDouble(), priceGap.max.toDouble());
    dateValues = RangeValues(dateGap.min.toDouble(), dateGap.max.toDouble());
    controller.addListener(_latestValue);
    _filter();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context).copyWith();
    _filter();
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: searchOpen
              ? TextField(
                  style: theme.textTheme.headline1,
                  autofocus: true,
                  controller: controller,
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: 'Поиск'),
                )
              : Text("Фильтрация списка", style: theme.textTheme.headline3),
          actions: [
            IconButton(
              icon: Icon(
                searchOpen ? Icons.close : Icons.search,
                color: theme.colorScheme.primary,
              ),
              onPressed: () {
                controller.clear();
                setState(() {
                  searchOpen = !searchOpen;
                });
              },
            ),
          ],
        ),
        body: Container(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                "Цена",
                style: theme.textTheme.headline2,
              ),
              RangeSlider(
                labels: RangeLabels('${priceValues.start.round()}' + '\$',
                    '${priceValues.end.round()}' + '\$'),
                activeColor: theme.colorScheme.primary,
                inactiveColor: theme.colorScheme.background,
                min: priceGap.min.toDouble(),
                max: priceGap.max.toDouble(),
                divisions: 10,
                onChanged: (newPrice) {
                  setState(() => priceValues = newPrice);
                },
                values: priceValues,
              ),
              Text(
                "Год выпуска",
                style: theme.textTheme.headline2,
              ),
              RangeSlider(
                labels: RangeLabels(
                    '${dateValues.start.round()}', '${dateValues.end.round()}'),
                activeColor: theme.colorScheme.primary,
                inactiveColor: theme.colorScheme.background,
                min: dateGap.min.toDouble(),
                max: dateGap.max.toDouble(),
                divisions: 10,
                onChanged: (newDate) {
                  setState(() => dateValues = newDate);
                },
                values: dateValues,
              ),
              ListTile(
                  leading: Text("Категория", style: theme.textTheme.headline1),
                  trailing: DropdownButton(
                    elevation: 16,
                    onChanged: (Category? item) {
                      setState(() {
                        filterCategory = item!;
                      });
                    },
                    hint: Text(
                        filterCategory == Category.all
                            ? 'Все'
                            : filterCategory == Category.film
                                ? 'Фильмы'
                                : filterCategory == Category.serial
                                    ? 'Сериалы'
                                    : 'Все',
                        style: theme.textTheme.headline1),
                    items: [
                      DropdownMenuItem<Category>(
                          child: new Text(
                            "Все",
                            style: theme.textTheme.headline1,
                          ),
                          value: Category.all),
                      DropdownMenuItem<Category>(
                          child: new Text("Фильмы",
                              style: theme.textTheme.headline1),
                          value: Category.film),
                      DropdownMenuItem<Category>(
                          child: new Text("Сериалы",
                              style: theme.textTheme.headline1),
                          value: Category.serial),
                    ],
                  )),
              Expanded(
                child: ListView.builder(
                    itemCount: cinemaList.length,
                    itemBuilder: (BuildContext context, int index) {
                      Cinema current = cinemaList.elementAt(index);
                      return Card(
                        elevation: 4,
                        child: ListTile(
                          title: Text('${current.name}'),
                          trailing: Text('${current.price}' + " \$"),
                          leading: Text('${current.date.year}'),
                        ),
                      );
                    }),
              ),
            ]),
          ),
        ));
  }

  _latestValue() {
    print("Search: ${controller.text}");
    setState(() {});
  }

  //getting the max and min values of price and date
  _getGap(String type) {
    List<int> list = [];
    if (type == 'price') {
      List.generate(initialCinemaList.length, (i) {
        int price = initialCinemaList[i].price;
        list.add(price);
      });
      print('min price:  ${list.reduce(min)}' +
          ' max price: ${list.reduce(max)}');
    }
    if (type == 'date') {
      List.generate(initialCinemaList.length, (i) {
        int date = initialCinemaList[i].date.year;
        list.add(date);
      });
      print(
          'min date:  ${list.reduce(min)}' + ' max date: ${list.reduce(max)}');
    }

    return Gap(max: list.reduce(max), min: list.reduce(min));
  }

  _filter() {
    List<Cinema> filterCinemaList = [];
    cinemaList.clear();

    //Filter by search
    String name = controller.text;

    if (name.isEmpty) {
      print('name is epmty');
      filterCinemaList.addAll(initialCinemaList);
    } else {
      print("filter cinema by search " + name);
      for (Cinema cinema in initialCinemaList) {
        if (cinema.name.toLowerCase().startsWith(name.toLowerCase().trim())) {
          filterCinemaList.add(cinema);
        }
      }
    }
    cinemaList = filterCinemaList;

    //Filter by category
    if (filterCategory != Category.all) {
      filterCinemaList = [];
      print("filter category " + filterCategory.toString());
      for (Cinema cinema in cinemaList) {
        if (cinema.category == filterCategory) {
          filterCinemaList.add(cinema);
        }
      }
      cinemaList = filterCinemaList;
    }

    //Filter by price
    filterCinemaList = [];
    for (Cinema cinema in cinemaList) {
      if (priceValues.start <= cinema.price &&
          cinema.price <= priceValues.end) {
        filterCinemaList.add(cinema);
      }
    }
    cinemaList = filterCinemaList;

    //Filter by date
    filterCinemaList = [];
    for (Cinema cinema in cinemaList) {
      if (dateValues.start <= cinema.date.year &&
          cinema.date.year <= dateValues.end) {
        filterCinemaList.add(cinema);
      }
    }
    cinemaList = filterCinemaList;
  }
}

class Gap {
  late int min;
  late int max;
  Gap({required this.max, required this.min});
}

enum Category {
  film,
  serial,
  all,
}

class Cinema {
  late final Category category;
  late final String name;
  late final int price;
  late final DateTime date;
  Cinema(
      {required this.name,
      required this.price,
      required this.date,
      required this.category});

  static final initialCinemaList = [
    Cinema(
      category: Category.film,
      name: 'Криминальное чтиво',
      date: DateTime.utc(1995, 09, 29),
      price: 1000,
    ),
    Cinema(
      category: Category.film,
      name: 'Убить Билла',
      date: DateTime.utc(2003, 12, 4),
      price: 1500,
    ),
    Cinema(
      category: Category.serial,
      name: 'Игра престолов',
      date: DateTime.utc(2011, 4, 17),
      price: 2000,
    ),
    Cinema(
      category: Category.serial,
      name: 'Игра престолов 2 сезон',
      date: DateTime.utc(2012, 4, 1),
      price: 400,
    ),
    Cinema(
      category: Category.serial,
      name: 'Игра престолов 3 сезон',
      date: DateTime.utc(2013, 3, 31),
      price: 1500,
    ),
  ];
}

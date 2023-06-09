import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/data/data.dart';
import 'package:to_do_list/data/repo/repository.dart';
import 'package:to_do_list/main.dart';
import 'package:to_do_list/screens/edit/edit.dart';
import 'package:to_do_list/screens/home/bloc/task_list_bloc.dart';
import 'package:to_do_list/widgets.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditTaskScreen(
                task: TaskEntity(),
              ),
            ),
          );
        },
        label: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Add New Task'),
            Icon(
              CupertinoIcons.add,
              size: 20,
            )
          ],
        ),
      ),
      body: BlocProvider<TaskListBloc>(
        create: (context) =>
            TaskListBloc(context.read<Repository<TaskEntity>>()),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                height: 110,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      themeData.colorScheme.primary,
                      themeData.colorScheme.primaryVariant
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'To Do List',
                            style: themeData.textTheme.headline6!
                                .apply(color: Colors.white),
                          ),
                          Image.asset(
                            'assets/share.png',
                            height: 30,
                            width: 30,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      Container(
                        height: 38,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(19),
                          color: themeData.colorScheme.onPrimary,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                            )
                          ],
                        ),
                        child: TextField(
                          controller: controller,
                          onChanged: (value) {
                            context
                                .read<TaskListBloc>()
                                .add(TaskListSearch(value));
                          },
                          decoration: const InputDecoration(
                            prefixIcon: Icon(CupertinoIcons.search),
                            label: Text('Search tasks ...'),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Consumer<Repository<TaskEntity>>(

                  builder:(context,model,child) {
                    context.read<TaskListBloc>().add(TaskListStarted());
                    return BlocBuilder<TaskListBloc, TaskListState>(
                    builder: (context, state) {
                      if (state is TaskListSuccess) {
                        return TaskList(items: state.items, themeData: themeData);
                      } else if (state is TaskListEmpty) {
                        return const EmptyState();
                      } else if (state is TaskListLoading ||
                          state is TaskListInitial) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (state is TaskListError) {
                        return Center(
                          child: Text(state.errorMesssage),
                        );
                      } else {
                        throw Exception('State is not valid ...');
                      }
                    },
                  );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  const TaskList({
    super.key,
    required this.items,
    required this.themeData,
  });

  final List<TaskEntity> items;
  final ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today',
                      style: themeData.textTheme.headline6!
                          .apply(fontSizeFactor: 0.9),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 70,
                      height: 3,
                      decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(1.5)),
                    )
                  ],
                ),
                MaterialButton(
                  color: const Color(0xffEAEFF5),
                  elevation: 0,
                  textColor: secondaryTextColor,
                  onPressed: () {
                    context.read<TaskListBloc>().add(TaskListDeleteAll());
                  },
                  child: const Row(
                    children: [
                      Text('Delet All'),
                      SizedBox(
                        width: 4,
                      ),
                      Icon(
                        CupertinoIcons.delete_solid,
                        size: 18,
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        } else {
          final TaskEntity task = items.toList()[index - 1];
          return TaskItem(task: task);
        }
      },
    );
  }
}

class TaskItem extends StatefulWidget {
  final double height = 84;
  const TaskItem({
    super.key,
    required this.task,
  });

  final TaskEntity task;

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    final priorityColor;
    switch (widget.task.priority) {
      case Priority.normal:
        priorityColor = normalPriority;
        break;
      case Priority.low:
        priorityColor = lowPriority;
        break;
      case Priority.high:
        priorityColor = highPriority;
        break;
    }
    ThemeData themeData = Theme.of(context);
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditTaskScreen(task: widget.task),
          ),
        );
      },
      onLongPress: () {
        final taskRepository =
            Provider.of<Repository<TaskEntity>>(context, listen: false);
        taskRepository.delete(widget.task);
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.only(left: 16, right: 16),
        height: 74,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: themeData.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        child: Row(
          children: [
            MyCheckBox(
              value: widget.task.isComplited,
              onTap: () {
                setState(() {
                  widget.task.isComplited = !widget.task.isComplited;
                });
              },
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Text(
                widget.task.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    decoration: widget.task.isComplited
                        ? TextDecoration.lineThrough
                        : null),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: priorityColor,
              ),
              width: 4,
              height: 84,
            )
          ],
        ),
      ),
    );
  }
}

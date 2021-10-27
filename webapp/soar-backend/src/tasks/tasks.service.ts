import { Injectable, NotImplementedException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateTaskDto } from './dto/create-task.dto';
import { UpdateTaskDto } from './dto/update-task.dto';
import { Task } from './entities/task.entity';

@Injectable()
export class TasksService {
  constructor(
    @InjectRepository(Task)
    private readonly taskRepository: Repository<Task>,
  ) {}

  create(createTaskDto: CreateTaskDto) {
    throw new NotImplementedException();
    // return this.taskRepository.save(createTaskDto);
  }

  findAll() {
    throw new NotImplementedException();

    // return this.taskRepository.find();
  }

  findOne(id: string) {
    throw new NotImplementedException();

    // return this.taskRepository.findOne(id);
  }

  update(id: string, updateTaskDto: UpdateTaskDto) {
    throw new NotImplementedException();

    // return this.taskRepository.update(id, updateTaskDto);
  }

  remove(id: string) {
    throw new NotImplementedException();

    // return this.taskRepository.delete(id);
  }
}

import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
} from 'typeorm';

@Entity()
export class Task {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('varchar', { nullable: false })
  title: string;

  @Column('varchar', { nullable: true })
  description: string;

  @CreateDateColumn()
  creation_date: Date;

  @Column()
  completed: boolean;
}

import { Column, CreateDateColumn, PrimaryGeneratedColumn } from 'typeorm';

export class Task {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('varchar', { nullable: false })
  title: string;

  @Column('varchar', { nullable: true })
  description: string;

  @CreateDateColumn()
  creation_date: Date;

  @Column('bool', { nullable: false })
  completed: boolean;
}

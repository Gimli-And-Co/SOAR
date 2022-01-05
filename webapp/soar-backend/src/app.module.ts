import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import configuration from './config/configuration';
import { Task } from './tasks/entities/task.entity';
import { TasksModule } from './tasks/tasks.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      envFilePath: '.env',
      load: [configuration],
      isGlobal: true,
    }),
    TypeOrmModule.forRootAsync({
      useFactory: async (config: ConfigService) => {
        const dbConf = config.get('database');
        console.log(dbConf);

        return {
          type: 'postgres',
          host: dbConf.host,
          username: dbConf.username,
          database: dbConf.database,
          password: dbConf.password,
          port: dbConf.port,
          // entities: [__dirname + '/**/*.entity{.ts,.js}'],
          entities: [Task],
          synchronize: true,
        };
      },
      inject: [ConfigService],
    }),
    TasksModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}

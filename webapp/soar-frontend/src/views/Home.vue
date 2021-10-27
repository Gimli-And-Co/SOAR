<template>
  <v-container>
    <v-row>
      <v-col cols="12" class="centered">
        <span class="text-h3 font-weight-medium primary--text">My tasks</span>
        <v-spacer></v-spacer>
        <v-btn @click="addModalState = true" color="primary"
          >Add a new task</v-btn
        >
      </v-col>
      <v-col cols="12">
        <v-divider></v-divider>
      </v-col>
    </v-row>
    <v-row>
      <v-list class="fwidth">
        <v-list-item
          v-for="(item, i) in tasks"
          :key="i"
          :three-line="item.description"
          class="fwidth"
        >
          <v-checkbox v-model="item.completed" class="mr-4"></v-checkbox>
          <v-list-item-content>
            <v-list-item-title
              ><span class="font-weight-medium">{{ item.title }}</span> -
              {{ item.creation_date | formatDate }}</v-list-item-title
            >
            <v-list-item-subtitle v-if="item.description">
              {{ item.description }}
            </v-list-item-subtitle>
          </v-list-item-content>
          <v-list-item-action>
            <v-hover v-slot="{ hover }">
              <v-btn
                icon
                @click="deleteTask(item.id)"
                :color="hover ? 'error' : ''"
                ><v-icon>mdi-delete</v-icon></v-btn
              >
            </v-hover>
          </v-list-item-action>
        </v-list-item>
      </v-list>
    </v-row>
    <v-dialog v-model="addModalState" width="33%">
      <v-card outlined>
        <v-card-title> Create your task ! </v-card-title>
        <v-card-actions>
          <v-form ref="form" lazy-validation v-model="formValid" class="fwidth">
            <v-text-field
              label="Title"
              placeholder="My task"
              required
              outlined
              v-model="taskTitleInput"
            >
            </v-text-field>
            <v-text-field
              label="Description (optional)"
              placeholder="Do the laundry"
              outlined
              v-model="taskDescriptionInput"
            >
            </v-text-field>
          </v-form>
        </v-card-actions>
        <v-card-actions>
          <v-btn text color="error" @click="cancelAddTask">Cancel</v-btn>
          <v-spacer></v-spacer>
          <v-btn text color="success" @click="addTask">Add</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-container>
</template>

<script>
export default {
  name: "Home",
  data: () => ({
    tasks: [],
    addModalState: false,
    taskTitleInput: "",
    taskDescriptionInput: "",
    formValid: false,
  }),
  mounted() {
    this.fetchAll().then(({ data }) => {
      this.tasks = data;
    });
  },
  methods: {
    async fetchAll() {
      return this.$axios.get("tasks");
    },
    async addTask() {
      if (this.formValid) {
        const { data } = await this.$axios.post("tasks", {
          title: this.taskTitleInput,
          description: this.taskDescriptionInput,
          completed: false,
        });
        this.tasks.push(data);
        this.cancelAddTask();
      }
    },
    cancelAddTask() {
      this.taskTitleInput = "";
      this.taskDescriptionInput = "";
      this.addModalState = false;
    },
    async deleteTask(id) {
      await this.$axios.delete(`tasks/${id}`);
      const index = this.tasks.findIndex((e) => e.id == id);
      this.tasks.splice(index, 1);
    },
  },
  filters: {
    formatDate(date) {
      const today = new Date(date);
      return today.toDateString();
    },
  },
};
</script>


<style lang="scss">
.centered {
  display: flex;
  justify-content: center;
  align-items: center;
}

.fwidth {
  width: 100%;
}

.fheight {
  height: 100%;
}
</style>
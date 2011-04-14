import rwmidi.*;

MidiInput input;
MidiOutput output;

int sx, sy;
float density = 0.5;
int[][][] world;
int note;

void setup()
{
  size(8, 8, P2D);
  frameRate(5);
  sx = width;
  sy = height;
  world = new int[sx][sy][2]; 

  input = RWMidi.getInputDevices()[2].createInput(this);
  output = RWMidi.getOutputDevices()[2].createOutput();

  // Set random cells to 'on'
  for (int i = 0; i < sx * sy * density; i++) {
    world[(int)random(sx)][(int)random(sy)][1] = 1;
  }
} 

void draw()
{
  background(0); 

  // Drawing and update cycle
  for (int x = 0; x < sx; x=x+1) {
    for (int y = 0; y < sy; y=y+1) {
      note = y * 16 + x;
      //if (world[x][y][1] == 1)
      if ((world[x][y][1] == 1) || (world[x][y][1] == 0 &amp;&amp; world[x][y][0] == 1))
      {
        world[x][y][0] = 1;
        set(x, y, #FFFFFF);
        output.sendNoteOn(0, note, 127);
      } else {
        output.sendNoteOn(0, note, 0);
      }
      if (world[x][y][1] == -1)
      {
        world[x][y][0] = 0;
      }
      world[x][y][1] = 0;
    }
  }
  // Birth and death cycle
  for (int x = 0; x < sx; x=x+1) {
    for (int y = 0; y < sy; y=y+1) {
      int count = neighbors(x, y);
      if (count == 3 &amp;&amp; world[x][y][0] == 0)
      {
        world[x][y][1] = 1;
      }
      if ((count < 2 || count > 3) &amp;&amp; world[x][y][0] == 1)
     {
        world[x][y][1] = -1;
      }
    }
  }
} 

void noteOnReceived(Note note) {
  println("note on " + note.getPitch() + ":"  + note.getVelocity());
  if (note.getVelocity() > 0) {
    int nx = note.getPitch() % 16;
    int ny = (note.getPitch() - nx) / 16;
    output.sendNoteOn(0, note.getPitch(), 100);
    println(nx);
    println(ny);
    world[nx][ny][1] = 1;
  }
}

// Count the number of adjacent cells 'on'
int neighbors(int x, int y)
{
  return world[(x + 1) % sx][y][0] +
         world[x][(y + 1) % sy][0] +
         world[(x + sx - 1) % sx][y][0] +
         world[x][(y + sy - 1) % sy][0] +
         world[(x + 1) % sx][(y + 1) % sy][0] +
         world[(x + sx - 1) % sx][(y + 1) % sy][0] +
         world[(x + sx - 1) % sx][(y + sy - 1) % sy][0] +
         world[(x + 1) % sx][(y + sy - 1) % sy][0];
}

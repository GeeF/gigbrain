/*
*                    GIGRIG
 *
 *
 *
 *
 *
 */


// Input Pins
#define MODEBUTTON 2

//output
#define SWITCHPIN_SRC   7

#define DEBOUNCE 200     // global debounce value

// modes
#define SWITCH_0 0
#define SWITCH_1 1

// Constants
#define CMD_MAX_LENGTH 64

long time     = 0;         // current time for debounce
long debounce = DEBOUNCE;  // debounce time

int mode = SWITCH_0;

// used for debug outputs via serial
void log (char *msg)
{
  Serial.print(millis());
  Serial.print(": ");
  Serial.print(msg);
  Serial.print("\n");
}
void logInt (unsigned int msg)
{
  Serial.print(millis());
  Serial.print(": ");
  Serial.print(msg);
  Serial.print("\n");
}


void switchMode ()
{
  switch (mode)
  {
  case SWITCH_0:
    mode = SWITCH_1;
    digitalWrite(SWITCHPIN_SRC, HIGH);
    log("Mode: SWITCH_1");
    break;
  case SWITCH_1:
    mode = SWITCH_0;
    digitalWrite(SWITCHPIN_SRC, LOW);
    log("Mode: SWITCH_0");
    break;
  default:
    mode = SWITCH_0;
    digitalWrite(SWITCHPIN_SRC, LOW);
    log("Mode: SWITCH_0 -- default");
    break;
  }
}

void readSerialCmd(char * cmd)
{
  int cnt = 0;

  while(Serial.available() > 0)
  {
    cmd[cnt] = Serial.read();
    ++cnt;
    delay(10); // wait for port to finish
  }
  cmd[cnt] = '\0';
}


void setup ()
{
  pinMode(SWITCHPIN_SRC,   OUTPUT);
  pinMode(MODEBUTTON, INPUT);

  // int. pullup resistors f. buttons
  digitalWrite(MODEBUTTON, HIGH);

  // output
  digitalWrite(SWITCHPIN_SRC,   LOW);

  // Serial Debug
  Serial.begin(9600);

  // MIDI Lib
  // MIDI.begin(4);
  Serial1.begin(31250);
}

//  plays a MIDI note.  Doesn't check to see that
//  cmd is greater than 127, or that data values are  less than 127:
void noteOn(int cmd, int pitch, int velocity) 
{
  Serial1.print(cmd, BYTE);
  Serial1.print(pitch, BYTE);
  Serial1.print(velocity, BYTE);
}


void loop ()
{ 
  char cmd[CMD_MAX_LENGTH];

  int modeButton = digitalRead(MODEBUTTON);
  // input of fireButton is handled via ext. interrupt

  // debouncing
  if (millis() - time > debounce)
  {
    if (modeButton == LOW)
      switchMode();
    time = millis();
  }

  if(Serial.available())
  {
    readSerialCmd(cmd);
    log(cmd);
    if(strcmp(cmd, "test") == 0)
    {
      noteOn(0x90, 55, 0x45);
      log("note sent!");
    }
    else
    {
      //int note = int(cmd[1]);
      noteOn(0x90, int(cmd[1]), 0x45);
    }
  }


  /*  // MIDI Loop
   for (int note = 0x1E; note < 0x5A; note ++) 
   {
   //Note on channel 1 (0x90), some note value (note), middle velocity (0x45):
   noteOn(0x90, note, 0x45);
   int d1 = 10;
   if(note % 3) d1 += 50;
   delay(d1);
   //Note on channel 1 (0x90), some note value (note), silent velocity (0x00):
   noteOn(0x90, note, 0x00);
   int d2 = 100;
   if(note % 4) d2 += 100;
   delay(d2);
   }
   */
}


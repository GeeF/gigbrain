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
    if(*cmd == "test")
    {
      Serial.print("Muh!");
    }
  }
}

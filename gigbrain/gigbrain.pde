/*
*                    GIGRIG
*
*
*
*
*
*/

#include "pins.h"

#define DEBOUNCE 200     // global debounce value

// Constants
#define CMD_MAX_LENGTH 64
#define MAX_CHANS 10 // max num of 10x dip switch arrays

long time     = 0;         // current time for debounce
long debounce = DEBOUNCE;  // debounce time

int mode = 0;

bool relays[9]; // Relay switch status
bool dips[MAX_CHANS-1][9];  // Values of dip switches
bool foots[MAX_CHANS-1];  // Foot Switches


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

// switch MMplex to channel 'ch'
void switchMMplex(int ch)
{
  digitalWrite(MMPLEX_A, bitRead(ch, 0));
  digitalWrite(MMPLEX_B, bitRead(ch, 1));
  digitalWrite(MMPLEX_C, bitRead(ch, 2));
  digitalWrite(MMPLEX_D, bitRead(ch, 3));
  delay(10); // give Multiplexer time to settle inputs
}

// switch Mplex to channel 'ch'
void switchMplex(int ch)
{
  digitalWrite(MPLEX_A, bitRead(ch, 0));
  digitalWrite(MPLEX_B, bitRead(ch, 1));
  digitalWrite(MPLEX_C, bitRead(ch, 2));
  digitalWrite(MPLEX_D, bitRead(ch, 3));
  delay(10); // give Multiplexer time to settle inputs
}

// Readout of all DIP Multiplexers
void readMultiplexers()
{
  // TODO: evtl. nur die reihe d. dips auslesen, dessen FOOT grad aktiv ist
  for(int i=0; i<MAX_CHANS; ++i)
  {
    switchMMplex(i);
    for(int j=0; j<10; ++j)
    {
      switchMplex(j);
      dips[i][j] = digitalRead(MMPLEX_X);
    }
  }
  
  log("----");
  Serial.print(millis());
  Serial.print(": ");
  for(int c=0; c<10; ++c)
  {
    Serial.print(dips[1][c]);
  }
  Serial.print("\n");
}

// switch a single relay on or off
void switchRelay (int num, bool high)
{
  if(high) digitalWrite(num, HIGH);
  else digitalWrite(num, LOW);
}

// set all relays according to DIP + FOOT input
void setRelays()
{
  for(int i=0; i<10; ++i)
  {
    //switchRelay(i, dips[]);
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
  //pinMode(SWITCHPIN_SRC,   OUTPUT);
  
  // Buttons
  pinMode(LCDPIN_1, INPUT);
  pinMode(LCDPIN_2, INPUT);
  pinMode(LCDPIN_3, INPUT);
  pinMode(LCDPIN_4, INPUT);

  // Fusstaster
  pinMode(FOOT1, INPUT);
  pinMode(FOOT2, INPUT);
  
  // Relays
  pinMode(RELAY1, OUTPUT);
  pinMode(RELAY2, OUTPUT);

  // Multiplexers
  pinMode(MMPLEX_A, OUTPUT);
  pinMode(MMPLEX_B, OUTPUT);
  pinMode(MMPLEX_C, OUTPUT);
  pinMode(MMPLEX_D, OUTPUT);
  pinMode(MMPLEX_X, INPUT);
  
  pinMode(MPLEX_A, OUTPUT);
  pinMode(MPLEX_B, OUTPUT);
  pinMode(MPLEX_C, OUTPUT);
  pinMode(MPLEX_D, OUTPUT);
  

  // initial pin config
  // int. pullup resistors f. buttons
  digitalWrite(LCDPIN_1, HIGH);
  digitalWrite(LCDPIN_2, HIGH);
  digitalWrite(LCDPIN_3, HIGH);
  digitalWrite(LCDPIN_4, HIGH);
  digitalWrite(FOOT1, HIGH);
  digitalWrite(FOOT2, HIGH);
  // and for MPlex Sum Outputs of Dips
  digitalWrite(MMPLEX_X, HIGH);

  // Multiplexer initial state
  digitalWrite(MMPLEX_A, LOW);
  digitalWrite(MMPLEX_B, LOW);
  digitalWrite(MMPLEX_C, LOW);
  digitalWrite(MMPLEX_D, LOW);
  digitalWrite(MPLEX_A, LOW);
  digitalWrite(MPLEX_B, LOW);
  digitalWrite(MPLEX_C, LOW);
  digitalWrite(MPLEX_D, LOW);
  
  // output
  //digitalWrite(SWITCHPIN_SRC,   LOW);
  digitalWrite(RELAY1, LOW);
  digitalWrite(RELAY2, LOW);
  
  // Serial Debug
  Serial.begin(9600);
  
  for(int i=1; i<10; ++i)
  {
    relays[i] = false; // LOW
  }
}

void loop ()
{ 
  char cmd[CMD_MAX_LENGTH];
  
  int buttons[3];
  for(int i=0; i<=3; ++i)
  {
    buttons[i] = digitalRead(i+2);
  }
  
  readMultiplexers();
  switchMMplex(1);
  Serial.print("0123456789\n");
  int buf[10];
  for(int i=0; i<10; ++i)
  {
    delay(50);
    switchMplex(i);
    buf[i] = digitalRead(MMPLEX_X);
  }
  Serial.print("\n");
  for(int i=0; i<10; ++i)
  {
    Serial.print(buf[i]);
  }
  Serial.print("\n");
  

  // debouncing
  if (millis() - time > debounce)
  {
    if (buttons[0] == LOW)
      {
      log("Switching Relay on.");
      switchRelay(RELAY1, true);
      }
    else
      {
      //log("Switching Relay off.");
      switchRelay(RELAY1, false);
      }
    time = millis();
  }
  
  delay(1000);
  // input of fireButton is handled via ext. interrupt
  
  
}


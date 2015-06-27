void serialEvent()
{
  char get_char;
  int res = 0;
  if(Serial2.available())
  {
    get_char = (char)Serial2.read();
    if(get_char != '+')
    {
      Serial.print("start char :");
      Serial.println(get_char);
      return;
    }
        get_char = (char)Serial2.read();
    switch(get_char)
    {
      case 'o':
        Serial.println("get command open");
        openDoor();
         //Serial2.println('o');
        break;
      case 'c':
        res = readInt();
        Serial.print("int result is ");
        Serial.println(res);
        setDisp(res);
        //Serial2.print('c');
        //Serial2.println(res);
      break;
      default:
        Serial.print("get command unknow:");
        Serial.println(get_char);
      }
    }
  
}

int readInt()
{
    String getString;
    int getChar;
    while(1)
    {
      if(Serial2.available() > 0)
      {
        getChar = Serial2.read();
        if(isDigit(getChar))
        {
          getString +=(char)getChar;
        }
        else
        {
          break;
        }
      }
    }
      return getString.toInt();
}

bool isDigit(char inChar)
{
    if('0'<= inChar && '9'>= inChar)
    {
      return 1;
    }
    else
    {
      return 0;
    }
}


void setDisp(int num)
{
  int tempnum = num;
clsarDisp();
  
  for(int i = 0; i < 4; i++)
  {
  tm1637.display(3-i,tempnum%10);
  tempnum /= 10;
  }
 }
void clsarDisp()
{
  for(int i = 0;i<4;i++)
  {
    tm1637.display(i,0);
  }  
}

  

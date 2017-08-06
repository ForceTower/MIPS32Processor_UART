#pragma once

#include <Windows.h>
#include <string>
#include <iostream>
#include <bitset>

using namespace std;

class CommunicationPort {
public:
    CommunicationPort ();
    ~CommunicationPort ();

    int OpenPort (const string& portname, DWORD BaudRate, BYTE ByteSize, BYTE StopBits, BYTE Parity);
    void ClosePort ();

    int SendData (const string& value);
    int SetupReceiver ();
    char ReceiveData ();

protected:
    HANDLE hCommunication;
    DCB dcbSerialParams = {0};
    COMMTIMEOUTS timeouts = {0};
    DWORD dwEventMask;
};


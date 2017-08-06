#include "CommunicationPort.h"


CommunicationPort::CommunicationPort () {
}


CommunicationPort::~CommunicationPort () {
    ClosePort ();
}

int CommunicationPort::OpenPort (const string& portname, DWORD BaudRate, BYTE ByteSize, BYTE StopBits, BYTE Parity) {

    hCommunication = CreateFile (
        portname.c_str (),
        GENERIC_READ | GENERIC_WRITE,
        0,
        NULL,
        OPEN_EXISTING,
        FILE_ATTRIBUTE_NORMAL,
        NULL
    );

    if (hCommunication == INVALID_HANDLE_VALUE) {
        cout << "Error Opening Communication Port: " << portname << endl;
        return -1;
    }

    dcbSerialParams.DCBlength = sizeof (dcbSerialParams);
    if (GetCommState (hCommunication, &dcbSerialParams) == 0) {
        cout << "Error getting device state" << endl;
        ClosePort ();
        return -2;
    }

    dcbSerialParams.BaudRate = BaudRate;
    dcbSerialParams.ByteSize = ByteSize;
    dcbSerialParams.StopBits = StopBits;
    dcbSerialParams.Parity   = Parity;

    if (SetCommState (hCommunication, &dcbSerialParams) == 0) {
        cout << "Error setting device parameters" << endl;
        ClosePort ();
        return -3;
    }

    timeouts.ReadIntervalTimeout         = 50;
    timeouts.ReadTotalTimeoutConstant    = 50;
    timeouts.ReadTotalTimeoutMultiplier  = 10;
    timeouts.WriteTotalTimeoutConstant   = 50;
    timeouts.WriteTotalTimeoutMultiplier = 10;

    if (SetCommTimeouts (hCommunication, &timeouts) == 0) {
        cout << "Error Setting Timeouts" << endl;
        ClosePort ();
        return -4;
    }

    return 0;
}

void CommunicationPort::ClosePort () {
    CloseHandle (hCommunication);
}

int CommunicationPort::SendData (const string& value) {
    const char* bytes = value.c_str ();

    int size = value.size ();
    
    DWORD written;

    if (!WriteFile (hCommunication, bytes, size, &written, NULL)) {
        cout << "Error Writting: " << value << endl;
        return -1;
    }

    //cout << "Write Success: " << value << " -- BIN: ";
    /*
    for (size_t i = 0; i < value.size (); i++) {
        cout << bitset<8> (value[i]);
    }
    */

    cout << endl;

    return 0;
}

int CommunicationPort::SetupReceiver () {
    if (!SetCommMask (hCommunication, EV_RXCHAR)) {
        cout << "Error in Setting Receiver Mask" << endl;
        return -1;
    }

    if (!WaitCommEvent (hCommunication, &dwEventMask, NULL)) {
        cout << "Error in Setting Receiver Event" << endl;
        return -2;
    }

    return 0;
}

char CommunicationPort::ReceiveData () {
    /*if (!SetCommMask (hCommunication, EV_RXCHAR)) {
        cout << "Error in Setting Receiver Mask" << endl;
        return -1;
    }

    if (!WaitCommEvent (hCommunication, &dwEventMask, NULL)) {
        cout << "Error in Setting Receiver Event" << endl;
        return -2;
    }*/

    char TempChar;
    DWORD NoBytesRead;
    
    ReadFile (hCommunication, &TempChar, sizeof (TempChar), &NoBytesRead, NULL);

    //cout << "Received: " << TempChar << "\t Int Value: " << static_cast<int>(TempChar) << endl;

    return TempChar;
}

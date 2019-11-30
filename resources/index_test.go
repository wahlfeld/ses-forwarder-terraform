package main

import "testing"

func TestLocalSesEvent(t *testing.T) {
	sesEvent := getLocalSesEvent()
	expectedEventSource := "aws:ses"
	if expectedEventSource != sesEvent.Records[0].EventSource {
		t.Errorf("Invalid SES eventSource: received %q, expected %q",
			sesEvent.Records[0].EventSource, expectedEventSource)
	}
}

package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
)

const (
	emailBucket    = "bucketName"
	emailKeyPrefix = "keyPrefix"

	// Replace sender@example.com with your "From" address.
	// This address must be verified with Amazon SES.
	Sender = "sender@example.com"

	// Replace recipient@example.com with a "To" address. If your account
	// is still in the sandbox, this address must be verified.
	Recipient = "recipient@example.com"

	// Specify a configuration set. To use a configuration
	// set, comment the next line and line 92.
	//ConfigurationSet = "ConfigSet"

	// The subject line for the email.
	Subject = "Amazon SES Test (AWS SDK for Go)"

	// The HTML body for the email.
	HtmlBody = "<h1>Amazon SES Test Email (AWS SDK for Go)</h1><p>This email was sent with " +
		"<a href='https://aws.amazon.com/ses/'>Amazon SES</a> using the " +
		"<a href='https://aws.amazon.com/sdk-for-go/'>AWS SDK for Go</a>.</p>"

	//The email body for recipients with non-HTML email clients.
	TextBody = "This email was sent with Amazon SES using the AWS SDK for Go."

	// The character encoding for the email.
	CharSet = "UTF-8"
)

type SesEvent struct {
	Records []struct {
		EventSource  string `json:"eventSource"`
		EventVersion string `json:"eventVersion"`
		Ses          struct {
			Mail struct {
				Timestamp        time.Time `json:"timestamp"`
				Source           string    `json:"source"`
				MessageID        string    `json:"messageId"`
				Destination      []string  `json:"destination"`
				HeadersTruncated bool      `json:"headersTruncated"`
				Headers          []struct {
					Name  string `json:"name"`
					Value string `json:"value"`
				} `json:"headers"`
				CommonHeaders struct {
					ReturnPath string   `json:"returnPath"`
					From       []string `json:"from"`
					Date       string   `json:"date"`
					To         []string `json:"to"`
					MessageID  string   `json:"messageId"`
					Subject    string   `json:"subject"`
				} `json:"commonHeaders"`
			} `json:"mail"`
			Receipt struct {
				Timestamp            time.Time `json:"timestamp"`
				ProcessingTimeMillis int       `json:"processingTimeMillis"`
				Recipients           []string  `json:"recipients"`
				SpamVerdict          struct {
					Status string `json:"status"`
				} `json:"spamVerdict"`
				VirusVerdict struct {
					Status string `json:"status"`
				} `json:"virusVerdict"`
				SpfVerdict struct {
					Status string `json:"status"`
				} `json:"spfVerdict"`
				DkimVerdict struct {
					Status string `json:"status"`
				} `json:"dkimVerdict"`
				DmarcVerdict struct {
					Status string `json:"status"`
				} `json:"dmarcVerdict"`
				Action struct {
					Type           string `json:"type"`
					FunctionArn    string `json:"functionArn"`
					InvocationType string `json:"invocationType"`
				} `json:"action"`
			} `json:"receipt"`
		} `json:"ses"`
	} `json:"Records"`
}

func getLocalSesEvent() SesEvent {
	var sesEvent SesEvent
	raw, err := ioutil.ReadFile("./ses_event_sample.json")
	if err != nil {
		fmt.Println(err.Error())
		os.Exit(1)
	}
	json.Unmarshal(raw, &sesEvent)

	return sesEvent
}

// Handler function to be invoked by AWS Lambda with an inbound SES email as
// the event.

func handler(sesEvent SesEvent) error {

	for _, record := range sesEvent.Records {
		fmt.Printf("[%s - %s] \n", record.EventVersion, record.EventSource)
	}

	return nil
}

func main() {
	sesEvent := getLocalSesEvent() // *** for local testing ***
	handler(sesEvent)

	// lambda.Start(Handler) // *** for real testing ***

}

// Fetches the message data from S3.

func getEmailFromS3() {
	sesEvent := getLocalSesEvent() // *** for local testing ***
	messageID := sesEvent.Records[0].Ses.Mail.MessageID

	// svc := s3.New(session.New())
	// input := &s3.CopyObjectInput{
	// 	Bucket:     aws.String(emailBucket),
	// 	Key:        aws.String(emailKeyPrefix),
	// 	CopySource: aws.String(messageID),
	// }

	result, err := svc.CopyObject(input)
	if err != nil {
		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			case s3.ErrCodeObjectNotInActiveTierError:
				fmt.Println(s3.ErrCodeObjectNotInActiveTierError, aerr.Error())
			default:
				fmt.Println(aerr.Error())
			}
		} else {
			// Print the error, cast err to awserr.Error to get the Code and
			// Message from an error.
			fmt.Println(err.Error())
		}
		return
	}

	fmt.Println(result)
}

// func parseEventFromSES() {

// }

// // Processes the message data, making updates to recipients and other headers
// // before forwarding message.

// func processEmailFromS3() {
// }

// // Forward email using the SES sendRawEmail command.

// func forwardEmail() {
// 	// Create a new session in the us-west-2 region.
// 	// Replace us-west-2 with the AWS Region you're using for Amazon SES.
// 	sesSession, err := session.NewSession(&aws.Config{
// 		Region: aws.String("us-west-2")},
// 	)

// 	// Create an SES session.
// 	session := ses.New(sesSession)

// 	// Assemble the email.
// 	input := &ses.SendEmailInput{
// 		Destination: &ses.Destination{
// 			CcAddresses: []*string{},
// 			ToAddresses: []*string{
// 				aws.String(Recipient),
// 			},
// 		},
// 		Message: &ses.Message{
// 			Body: &ses.Body{
// 				Html: &ses.Content{
// 					Charset: aws.String(CharSet),
// 					Data:    aws.String(HtmlBody),
// 				},
// 				Text: &ses.Content{
// 					Charset: aws.String(CharSet),
// 					Data:    aws.String(TextBody),
// 				},
// 			},
// 			Subject: &ses.Content{
// 				Charset: aws.String(CharSet),
// 				Data:    aws.String(Subject),
// 			},
// 		},
// 		Source: aws.String(Sender),
// 		// Uncomment to use a configuration set
// 		//ConfigurationSetName: aws.String(ConfigurationSet),
// 	}

// 	// Attempt to send the email.
// 	result, err := session.SendEmail(input)

// 	// Display error messages if they occur.
// 	if err != nil {
// 		if aerr, ok := err.(awserr.Error); ok {
// 			switch aerr.Code() {
// 			case ses.ErrCodeMessageRejected:
// 				fmt.Println(ses.ErrCodeMessageRejected, aerr.Error())
// 			case ses.ErrCodeMailFromDomainNotVerifiedException:
// 				fmt.Println(ses.ErrCodeMailFromDomainNotVerifiedException, aerr.Error())
// 			case ses.ErrCodeConfigurationSetDoesNotExistException:
// 				fmt.Println(ses.ErrCodeConfigurationSetDoesNotExistException, aerr.Error())
// 			default:
// 				fmt.Println(aerr.Error())
// 			}
// 		} else {
// 			// Print the error, cast err to awserr.Error to get the Code and
// 			// Message from an error.
// 			fmt.Println(err.Error())
// 		}

// 		return
// 	}

// 	fmt.Println("Email Sent to address: " + Recipient)
// 	fmt.Println(result)
// }

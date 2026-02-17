package main

import (
	"encoding/binary"
	"encoding/json"
	"io"
	"log"
	"os"
	"os/exec"
	"syscall"
)

const EV_KEY = 0x01

var keyMap = map[string]uint16{
	"BTN_SOUTH": 0x130,
	"BTN_EAST":  0x131,
	"BTN_NORTH": 0x133,
	"BTN_WEST":  0x134,
	"BTN_TL":    0x136,
	"BTN_TR":    0x137,
	"BTN_MODE":  0x13c,
}

type Config struct {
	Device   string    `json:"device"`
	LogFile  string    `json:"log_file"`
	Bindings []Binding `json:"bindings"`
}

type Binding struct {
	Key    string `json:"key"`
	Script string `json:"script"`
}

type inputEvent struct {
	Time  [16]byte
	Type  uint16
	Code  uint16
	Value int32
}

func main() {
	if len(os.Args) < 2 {
		log.Fatal("Usage: ds-remote config.json [--daemon]")
	}

	configPath := os.Args[1]
	daemon := len(os.Args) > 2 && os.Args[2] == "--daemon"

	if daemon {
		daemonize(configPath)
	}

	cfg := loadConfig(configPath)
	setupLogging(cfg.LogFile)

	log.Println("Starting ds-remote...")

	device, err := os.Open(cfg.Device)
	if err != nil {
		log.Fatal(err)
	}
	defer device.Close()

	bindings := buildBindings(cfg)

	for {
		var ev inputEvent
		err := binary.Read(device, binary.LittleEndian, &ev)
		if err != nil {
			log.Fatal(err)
		}

		if ev.Type == EV_KEY && ev.Value == 1 {
			for code, script := range bindings {
				if ev.Code == code {
					log.Printf("Key triggered: %d -> %s\n", code, script)
					go runScript(script)
				}
			}
		}
	}
}

func loadConfig(path string) Config {
	file, err := os.Open(path)
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	var cfg Config
	err = json.NewDecoder(file).Decode(&cfg)
	if err != nil {
		log.Fatal(err)
	}

	return cfg
}

func buildBindings(cfg Config) map[uint16]string {
	result := make(map[uint16]string)

	for _, b := range cfg.Bindings {
		code, ok := keyMap[b.Key]
		if !ok {
			log.Fatalf("Unknown key: %s", b.Key)
		}
		result[code] = b.Script
	}

	return result
}

func runScript(path string) {
	cmd := exec.Command("/bin/bash", path)
	err := cmd.Start()
	if err != nil {
		log.Println("Script error:", err)
	}
}

func setupLogging(logPath string) {
	if logPath == "" {
		return
	}

	f, err := os.OpenFile(logPath, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		log.Fatal(err)
	}

	mw := io.MultiWriter(os.Stdout, f)
	log.SetOutput(mw)
}

func daemonize(configPath string) {
	if os.Getppid() == 1 {
		return
	}

	cmd := exec.Command(os.Args[0], configPath)
	cmd.SysProcAttr = &syscall.SysProcAttr{}

	err := cmd.Start()
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(0)
}
